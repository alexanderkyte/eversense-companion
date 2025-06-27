import datetime
import argparse
import logging
import time
import json

import requests


class EversenseClient:
    LOGIN_URL = "https://usiamapi.eversensedms.com/connect/token"
    USER_DETAILS_URL = "https://usapialpha.eversensedms.com/api/care/GetFollowingPatientList"
    GLUCOSE_URL = "https://usapialpha.eversensedms.com/api/care/GetFollowingUserSensorGlucose"


    def __init__(self, username, password, otp_factor="email", otp_mode="request"):
        self.username = username
        self.password = password
        self.otp_factor = otp_factor
        self.otp_mode = otp_mode
        self.access_token = None
        self.token_expiry = 0
        self.user_id = None
        self.logger = logging.getLogger(self.__class__.__name__)

    def login(self):
        data = {
            "grant_type": "password",
            "client_id": "eversenseMMAAndroid",
            "client_secret": "6ksPx#]~wQ3U",
            "username": self.username,
            "password": self.password,
        }
        headers = {'Content-Type': 'application/x-www-form-urlencoded'}
        try:
            resp = requests.post(self.LOGIN_URL, data=data, headers=headers)
            resp.raise_for_status()
            token_data = resp.json()
            self.access_token = token_data["access_token"]
            self.token_expiry = time.time() + token_data.get("expires_in", 43200) - 60
            self.logger.debug(f"[Login] Success, token expires in {token_data.get('expires_in', 43200)}s")
            return True
        except Exception as e:
            self.logger.error(f"[Login] Failed: {e}")
            return False

    def ensure_token_valid(self):
        if not self.access_token or time.time() > self.token_expiry:
            self.logger.debug("[Token] Expired or missing, re-login needed")
            if not self.login():
                raise RuntimeError("Login failed, cannot refresh token")

    def fetch_user_id(self):
        self.ensure_token_valid()
        headers = {"Authorization": f"Bearer {self.access_token}"}
        try:
            resp = requests.get(self.USER_DETAILS_URL, headers=headers)
            resp.raise_for_status()
            user_data = resp.json()
            self.user_id = user_data[0].get("UserID")
            self.logger.debug(f"[User] UserID fetched: {self.user_id}")
            trends = {}
            trends[0] = "STALE"
            trends[1] = "FALLING_FAST"
            trends[2] = "FALLING"
            trends[3] = "FLAT"
            trends[4] = "RISING"
            trends[5] = "RISING_FAST"
            trends[6] = "FALLING_RAPID"
            trends[7] = "RAISING_RAPID"

            state = {}
            state["currentGlucose"] =  user_data[0].get("CurrentGlucose")
            state["glucoseTrend"] = trends[user_data[0].get("GlucoseTrend")]
            state["isTransmitterConnected"] = user_data[0].get("IsTransmitterConnected")
            return self.user_id, state
        except Exception as e:
            self.logger.error(f"[User] Failed to fetch UserID: {e}")
            return None

    def fetch_glucose_data(self, from_dt: datetime.datetime, to_dt: datetime.datetime):
        self.ensure_token_valid()
        headers = {"Authorization": f"Bearer {self.access_token}"}

        json_data = {
            "UserID": self.user_id,
            "startDate": from_dt.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
            "endDate": to_dt.strftime("%Y-%m-%dT%H:%M:%S.000Z"),
        }
        self.logger.debug(f"[Glucose] Fetching glucose data from {from_dt} to {to_dt}")
        try:
            resp = requests.get(self.GLUCOSE_URL, json_data, headers=headers)
            resp.raise_for_status()
            data = resp.json()
            accum = []
            for event in data:
                if "EventDate" in event:
                    local_time = datetime.datetime.fromisoformat(event["EventDate"])
                    utc_time = local_time.astimezone(datetime.timezone.utc)
                    event["EventDate"] = utc_time.astimezone()
                if event["EventTypeID"] == 1 and event["Deleted"] == False:
                    accum.append((event["EventDate"], event["Value"]))
            return accum
        except Exception as e:
            self.logger.error(f"[Glucose] Fetch failed: {e}")
            return None

def fetch_history(client):
    if not client.access_token:
        if not client.login():
            self.logger.error("Could not log in")
            return

    user_id, state = client.fetch_user_id()
    if user_id is None:
        self.logger.error("Get user info failed")
        return
    # Load last 24h glucose data from API
    now = datetime.datetime.now(datetime.timezone.utc)
    from_dt = now - datetime.timedelta(hours=24)
    glucose_data = client.fetch_glucose_data(from_dt, now)
    if not glucose_data:
        self.logger.error("No data")
        return
    for row in glucose_data:
        print(row)
    return

def fetch_current(client):
    if not client.access_token:
        if not client.login():
            self.logger.error("Could not log in")
            return

    user_id, state = client.fetch_user_id()
    if user_id is None:
        self.logger.error("Get user info failed")
        return
    glucose_data = state
    if not glucose_data:
        self.logger.error("No data")
        return
    print(glucose_data)

def main(client):
    fetch_history(client)
    while True:
        fetch_current(client)
        time.sleep(60)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run the assistant agent with a specified model.')
    parser.add_argument('--username', type=str, help='Username of follower account, email address')
    parser.add_argument('--password', type=str, help='Password of follower account')
    args = parser.parse_args()

    client = EversenseClient(args.username, args.password)
    main(client)