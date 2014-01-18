/*
 *
 * @options {array}	list of options
 *
 * options = [ 100, 200 ]
 */
function createCss(options) {
	var height = jQuery("#today").height();

	jQuery(options).each(function(i) {
		jQuery(".all_users_workload")
			.append('<div class="month_end_' + i + '"></div>');
		jQuery(".all_users_workload .month_end_" + i)
			.css({
				height: height + "px",
				top: "-" + (height * (i + 1)) + "px",
				background: "none repeat scroll 0 0 #999",
				left: this + "px",
				position: "relative",
				width: "3px"
			});
	})
	jQuery(".all_users_workload").css('max-height', height);
}

jQuery.fn.CreateCss = createCss;

jQuery(document).ready(function($) {
	$(".workload")
		.on("mouseover", ".info-title", function(e) {
			// hide all info areas that are currently showing
			$(".workload .info-widget:visible").hide();

			// show the current info area
			$(this).parents(".user_each_hours").find(".info-widget").fadeIn("slow");
		})

		// hide the info area when cursor leave the area
		.on("mouseleave", ".user_each_hours:has(.info-widget:visible)", function(e) {
			$(this).find(".info-widget").fadeOut();
		})

		// user_each_hours
		.on({
			mouseenter: function(e) {
				var id_tarea = $(this).attr('id');
				$('.workload.tarea.' + id_tarea).css({
					'margin-bottom': '1px',
					'padding-top': '1px',
					'border': '1px solid #ccc',
					'background': '#ebebec'
				});
			},
			mouseleave: function(e) {
				var id_tarea = $(this).attr('id');
				$('.workload.tarea.' + id_tarea).css({
					'margin-bottom': '2px',
					'padding-top': '2px',
					'border': '0px solid #ccc',
					'background' : 'transparent'
				});
			}
		}, ".user_each_hours");

	var top_obj = $("#top");

	// make the header sticky
	$(".all").on("scroll", function(e) {
		var container_scroll_top = $(this).scrollTop();

		top_obj
			.stop()
			.animate({
				top: container_scroll_top
			}, "fast");
	});

	//COMPROBAR SI UNA TAREA REMANENTE TIENE SUBTAREAS ASOCIADAS
/*
	jQuery(".workload .user_total_hours").each(function(){
		if (jQuery(this).find(".user_each_hours").length == 0) {
			jQuery(this).css('height','50px');
		}
	});
*/
	// make rows equal height
	jQuery(".workload .user").each(function(i) {
		jQuery(".total_user_workload:eq("+i+")").height( jQuery(this).height());
	});
});
