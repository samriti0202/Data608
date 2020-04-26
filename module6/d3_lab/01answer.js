// set the dimensions and margins of the graph
var margin = {top: 0, right: 0, bottom: 0, left: 0},
    width = 1180 - margin.left - margin.right,
    height = 580 - margin.top - margin.bottom;



//Read the data
d3.csv("https://raw.githubusercontent.com/samriti0202/Data608/master/module6/d3_lab/ue_industry.csv",

// Now I can use this dataset:
  function(data) {

// Add X axis -->
    var x = d3.scaleLinear()
      .domain(d3.extent(data , d => +d.index))
      .range([ 10, width ]);

// Add Y axis
    var y = d3.scaleLinear()
       .domain(d3.extent(data , d => +d.Agriculture))
	.range([ height, 10 ]);

    // Add the line
d3.select("#answer1")
      .append("path")
      .datum(data)
      .attr("fill", "none")
      .attr("stroke", "#2e2928")
      .attr("d", d3.line()
        .x(function(d) { return x(d.index) })
        .y(function(d) { return y(d. Agriculture) })
        )

})