d3.csv('https://raw.githubusercontent.com/samriti0202/Data608/master/module6/d3_lab/ue_industry.csv', data => {

    const xScale = d3.scaleLinear()
        .domain(d3.extent(data,d => +d.index))
        .range([1180, 20]);

    const yScale = d3.scaleLinear()
        .domain(d3.extent(data,d => +d.Agriculture))
        .range([580, 20]);
	 //alert("TEST111111")
    d3.select('#part4')
        .selectAll('circle')
        .data(data)
        .enter()
        .append('circle')
        .attr('r', d => 5)
        .attr('cx', d => xScale(d.index))
        .attr('cy', d => yScale(d.Agriculture));

});