define(['jquery', 'd3', 'spin', 'mds'],
function($, d3, Spinner, mds) {
return {
	state : {
		"view": null
	},

	handle_data2: function(data, control) {
		var self = this;
		var names = data.names;
		var coordinates = data.coords;

		var svg = d3.select("#mds-plot").append("svg")
			.style("width", "100%")
			.style("height", "100%")
			.call(d3.zoom().on("zoom", function() {
				self.state.view = d3.event.transform;

				d3.selectAll(this.childNodes)
					.attr("transform", "translate(" + d3.event.transform.x + "," + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
			}));

		i = 0;
		names.forEach(function(sp, i) {
			var coord = coordinates[i];

			var node = svg.append("svg:image")
				.attr("id", sp)
				.attr("x", coord[0] + 1.0*$(".mds").width()/2)
				.attr("y", coord[1] + 1.0*$(".mds").height()/2)
				.attr("width", 20)
				.attr("height", 20)
				.attr("xlink:href", "/static/img/" + sp + ".png")
				.on("mouseover", function() {
					d3.select(this)
						.attr("width", 200)
						.attr("height", 200);

					d3.select('#' + sp + '_rect')
						.attr("width", 200)
						.attr("height", 200);

					var front_el = $(this.parentNode).children()[$(this.parentNode).children().length-1];
					this.parentNode.insertBefore(this, front_el);
					this.parentNode.insertBefore(front_el, this);

					this.parentNode.insertBefore(document.getElementById(
						sp + '_rect'), front_el);
					this.parentNode.insertBefore(front_el, document.getElementById(
						sp + '_rect'));
				})
				.on("mouseout", function() {
					d3.select(this)
						.attr("width", 20)
						.attr("height", 20);
					d3.select('#' +  sp + '_rect')
						.attr("width", 20)
						.attr("height", 20);
				})
				.on('click', function() {
					if (control.searchControl._selectedSpecies[0] !== undefined &&
						control.searchControl._selectedSpecies[0]._latin !== sp) {
							control.selectSpecies(sp);
					}
				});

				svg.append('svg:rect')
					.attr("id", sp + '_rect')
					.attr("x", coord[0] + 1.0*$(".mds").width()/2)
					.attr("y", coord[1] + 1.0*$(".mds").height()/2)
					.attr("width", 20)
					.attr("height", 20)
					.attr('stroke', 'none')
					.attr('fill', 'none');
		});


		/* Highligh the image background if species are selected */
		for (var i = 0; i < 3; i++) {
			if (control.searchControl._selectedSpecies[i] !== undefined) {
				control.highlightSpeciesImage(
					control.searchControl._selectedSpecies[i]._latin,
					control.speciesColor[i]
				);
			}
		}

		if (window.spinner)
			window.spinner.stop();
	},

	handle_data: function(data) {
		var self = this;
		var sp_count = Object.keys(data).length;
		var distances = new Array(sp_count);

		var i = 0;
		for (var sp1 in data) {
			distances[i] = new Array(sp_count);

			var j = 0;
			for (var sp2 in data[sp1]) {
				distances[i][j] = (1-data[sp1][sp2]) * 1000;
				j++;
			}

			i++;
		}

		var mdsTime = new Date().getTime();
		var coordinates = mds.classic(distances, 2);

		var svg = d3.select("#mds-plot").append("svg")
			.style("width", "100%")
			.style("height", "100%")
			.call(d3.zoom().on("zoom", function() {
				self.state.view = d3.event.transform;

				d3.selectAll(this.childNodes)
					.attr("transform", "translate(" + d3.event.transform.x + "," + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
			}));

		i = 0;
		for (var sp in data) {
			var coord = coordinates[i];

			var node = svg.append("svg:image")
				.attr("id", sp)
				.attr("x", coord[0] + 1.0*$(".mds").width()/2)
				.attr("y", coord[1] + 1.0*$(".mds").height()/2)
				.attr("width", 20)
				.attr("height", 20)
				.attr("xlink:href", "/static/img/" + sp + ".png")
				.on("mouseover", function() {
					d3.select(this)
						.attr("width", 200)
						.attr("height", 200);

					var front_el = $(this.parentNode).children()[$(this.parentNode).children().length-1];
					this.parentNode.insertBefore(this, front_el);
					this.parentNode.insertBefore(front_el, this);
				})
				.on("mouseout", function() {
					d3.select(this)
						.attr("width", 20)
						.attr("height", 20);
				});

			i++;
		}

		if (window.spinner)
			window.spinner.stop();
	},

	run_mds: function(type, control) {
		var self = this;
		var spinner = new Spinner({color: "#444", lines: 20, scale: 2}).spin(
			document.getElementsByClassName("mds")[0]
		);

		window.spinner = spinner;

		if (window[type] !== undefined) {
			this.handle_data2(window[type], control);
			return;
		}

		var url = window.location.href.split('?')[0] + 'mds/';
		var csrftoken = $("input[name='csrfmiddlewaretoken']").val();

		if (type === undefined)
			type = "ssi";

		window.ajaxTime = new Date().getTime();
		$.ajax({
			url: url,
			method: 'POST',
			data: {
				'type': type
			},
			headers: {
				'X-CSRFToken': csrftoken,
			},
			success: function(data) {
				window[type] = data;
				self.handle_data2(data, control);
			},
			error: function() {
				$('#mds-border').css('display', 'none');
			}
		});
	},

};
});
