/**
 * D3.js Chart Component for Blood Glucose Visualization
 * 
 * This module creates a stock ticker style chart for displaying blood glucose levels
 * with colored zones for different glucose ranges.
 */

class GlucoseChart {
    constructor(containerId) {
        this.containerId = containerId;
        this.svg = null;
        this.data = [];
        this.margin = { top: 20, right: 30, bottom: 40, left: 60 };
        this.width = 800;
        this.height = 400;
        this.innerWidth = this.width - this.margin.left - this.margin.right;
        this.innerHeight = this.height - this.margin.top - this.margin.bottom;
        
        // Glucose level thresholds
        this.thresholds = {
            low: 80,
            high: 130
        };
        
        // D3 scales
        this.xScale = null;
        this.yScale = null;
        this.line = null;
        
        this.init();
    }
    
    init() {
        // Create SVG element
        this.svg = d3.select(`#${this.containerId}`)
            .attr('width', this.width)
            .attr('height', this.height);
        
        // Create main group for the chart
        this.chartGroup = this.svg.append('g')
            .attr('transform', `translate(${this.margin.left}, ${this.margin.top})`);
        
        // Create scales
        this.xScale = d3.scaleTime()
            .range([0, this.innerWidth]);
        
        this.yScale = d3.scaleLinear()
            .domain([0, 400])
            .range([this.innerHeight, 0]);
        
        // Create line generator
        this.line = d3.line()
            .x(d => this.xScale(new Date(d.timestamp)))
            .y(d => this.yScale(d.value))
            .curve(d3.curveMonotoneX);
        
        // Create axes
        this.createAxes();
        
        // Create glucose zones
        this.createGlucoseZones();
        
        // Create grid
        this.createGrid();
    }
    
    createAxes() {
        // X-axis
        this.xAxisGroup = this.chartGroup.append('g')
            .attr('class', 'x-axis axis')
            .attr('transform', `translate(0, ${this.innerHeight})`);
        
        // Y-axis
        this.yAxisGroup = this.chartGroup.append('g')
            .attr('class', 'y-axis axis');
        
        // Y-axis label
        this.svg.append('text')
            .attr('transform', 'rotate(-90)')
            .attr('y', 0 - this.margin.left)
            .attr('x', 0 - (this.height / 2))
            .attr('dy', '1em')
            .style('text-anchor', 'middle')
            .style('font-size', '12px')
            .style('fill', '#7f8c8d')
            .text('Blood Glucose (mg/dL)');
        
        // X-axis label
        this.svg.append('text')
            .attr('transform', `translate(${this.width / 2}, ${this.height - 6})`)
            .style('text-anchor', 'middle')
            .style('font-size', '12px')
            .style('fill', '#7f8c8d')
            .text('Time');
    }
    
    createGlucoseZones() {
        // Low zone (below 80)
        this.chartGroup.append('rect')
            .attr('class', 'zone-low')
            .attr('x', 0)
            .attr('y', this.yScale(this.thresholds.low))
            .attr('width', this.innerWidth)
            .attr('height', this.yScale(0) - this.yScale(this.thresholds.low));
        
        // Good zone (80-130)
        this.chartGroup.append('rect')
            .attr('class', 'zone-good')
            .attr('x', 0)
            .attr('y', this.yScale(this.thresholds.high))
            .attr('width', this.innerWidth)
            .attr('height', this.yScale(this.thresholds.low) - this.yScale(this.thresholds.high));
        
        // High zone (above 130)
        this.chartGroup.append('rect')
            .attr('class', 'zone-high')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', this.innerWidth)
            .attr('height', this.yScale(this.thresholds.high));
        
        // Zone labels
        this.chartGroup.append('text')
            .attr('x', this.innerWidth - 10)
            .attr('y', this.yScale(40))
            .attr('text-anchor', 'end')
            .style('font-size', '11px')
            .style('fill', '#f39c12')
            .style('font-weight', 'bold')
            .text('TOO LOW');
        
        this.chartGroup.append('text')
            .attr('x', this.innerWidth - 10)
            .attr('y', this.yScale(105))
            .attr('text-anchor', 'end')
            .style('font-size', '11px')
            .style('fill', '#27ae60')
            .style('font-weight', 'bold')
            .text('GOOD');
        
        this.chartGroup.append('text')
            .attr('x', this.innerWidth - 10)
            .attr('y', this.yScale(200))
            .attr('text-anchor', 'end')
            .style('font-size', '11px')
            .style('fill', '#e74c3c')
            .style('font-weight', 'bold')
            .text('TOO HIGH');
    }
    
    createGrid() {
        // Horizontal grid lines
        this.chartGroup.append('g')
            .attr('class', 'grid')
            .selectAll('line')
            .data(this.yScale.ticks(10))
            .enter()
            .append('line')
            .attr('x1', 0)
            .attr('x2', this.innerWidth)
            .attr('y1', d => this.yScale(d))
            .attr('y2', d => this.yScale(d));
    }
    
    updateChart(data) {
        this.data = data;
        
        if (data.length === 0) {
            return;
        }
        
        // Update x-scale domain
        const extent = d3.extent(data, d => new Date(d.timestamp));
        this.xScale.domain(extent);
        
        // Update axes
        this.xAxisGroup.call(d3.axisBottom(this.xScale)
            .tickFormat(d3.timeFormat('%H:%M')));
        
        this.yAxisGroup.call(d3.axisLeft(this.yScale));
        
        // Update line
        const path = this.chartGroup.selectAll('.line')
            .data([data]);
        
        path.enter()
            .append('path')
            .attr('class', 'line')
            .merge(path)
            .transition()
            .duration(750)
            .attr('d', this.line);
        
        // Update dots
        const dots = this.chartGroup.selectAll('.dot')
            .data(data);
        
        dots.enter()
            .append('circle')
            .attr('class', 'dot')
            .attr('r', 4)
            .merge(dots)
            .transition()
            .duration(750)
            .attr('cx', d => this.xScale(new Date(d.timestamp)))
            .attr('cy', d => this.yScale(d.value))
            .attr('class', d => `dot ${this.getGlucoseCategory(d.value)}`);
        
        dots.exit().remove();
        
        // Add tooltips
        this.addTooltips();
    }
    
    addTooltips() {
        const tooltip = d3.select('body').selectAll('.tooltip')
            .data([null]);
        
        const tooltipEnter = tooltip.enter()
            .append('div')
            .attr('class', 'tooltip')
            .style('opacity', 0)
            .style('position', 'absolute')
            .style('background', 'rgba(0, 0, 0, 0.8)')
            .style('color', 'white')
            .style('padding', '8px')
            .style('border-radius', '4px')
            .style('font-size', '12px')
            .style('pointer-events', 'none');
        
        const tooltipMerged = tooltipEnter.merge(tooltip);
        
        this.chartGroup.selectAll('.dot')
            .on('mouseover', (event, d) => {
                const category = this.getGlucoseCategory(d.value);
                const categoryText = category === 'good' ? 'Good' : 
                                   category === 'high' ? 'Too High' : 'Too Low';
                
                tooltipMerged.transition()
                    .duration(200)
                    .style('opacity', .9);
                
                tooltipMerged.html(`
                    <strong>${d.value} mg/dL</strong><br/>
                    ${new Date(d.timestamp).toLocaleString()}<br/>
                    Status: ${categoryText}<br/>
                    Trend: ${d.trend || 'stable'}
                `)
                    .style('left', (event.pageX + 10) + 'px')
                    .style('top', (event.pageY - 28) + 'px');
            })
            .on('mouseout', () => {
                tooltipMerged.transition()
                    .duration(500)
                    .style('opacity', 0);
            });
    }
    
    addDataPoint(newDataPoint) {
        // Add new data point
        this.data.push(newDataPoint);
        
        // Keep only last 144 data points (24 hours at 10-minute intervals)
        if (this.data.length > 144) {
            this.data.shift();
        }
        
        // Re-render chart
        this.updateChart(this.data);
    }
    
    getGlucoseCategory(value) {
        if (value < this.thresholds.low) {
            return 'low';
        } else if (value > this.thresholds.high) {
            return 'high';
        } else {
            return 'good';
        }
    }
    
    getLatestReading() {
        if (this.data.length === 0) {
            return null;
        }
        
        return this.data[this.data.length - 1];
    }
    
    resize() {
        // Get container dimensions
        const container = document.getElementById(this.containerId).parentElement;
        const containerWidth = container.clientWidth;
        
        // Update dimensions
        this.width = Math.max(600, containerWidth - 40);
        this.innerWidth = this.width - this.margin.left - this.margin.right;
        
        // Update SVG size
        this.svg.attr('width', this.width);
        
        // Update scales
        this.xScale.range([0, this.innerWidth]);
        
        // Update zones
        this.chartGroup.selectAll('.zone-low, .zone-good, .zone-high')
            .attr('width', this.innerWidth);
        
        // Update grid
        this.chartGroup.selectAll('.grid line')
            .attr('x2', this.innerWidth);
        
        // Re-render chart
        this.updateChart(this.data);
    }
}

// Make the chart class available globally
window.GlucoseChart = GlucoseChart;