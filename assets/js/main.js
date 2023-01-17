(function($) {

	$(function() {

		var	$window = $(window),
			$body = $('body'),
			$wrapper = $('#wrapper');

			// Add (and later, on load, remove) "loading" class.
			$body.addClass('loading');

			$window.on('load', function() {
				window.setTimeout(function() {
					$body.removeClass('loading');
				}, 100);
			});

		// Prevent transitions/animations on resize.
			var resizeTimeout;

			$window.on('resize', function() {

				window.clearTimeout(resizeTimeout);

				$body.addClass('resizing');

				resizeTimeout = window.setTimeout(function() {
					$body.removeClass('resizing');
				}, 100);

			});
		// Scroll back to top.
			$window.scrollTop(0);

		
		// Panels.
			var $panels = $('.panel');

			$panels.each(function() {

				var $this = $(this),
					$toggles = $('[href="#' + $this.attr('id') + '"]'),
					$closer = $('<div class="closer" />').appendTo($this);

				// Closer.
					$closer
						.on('click', function(event) {
							$this.trigger('---hide');
						});

				// Events.
					$this
						.on('click', function(event) {
							event.stopPropagation();
						})
						.on('---toggle', function() {

							if ($this.hasClass('active'))
								$this.triggerHandler('---hide');
							else
								$this.triggerHandler('---show');

						})
						.on('---show', function() {

							// Hide other content.
								if ($body.hasClass('content-active'))
									$panels.trigger('---hide');

							// Activate content, toggles.
								$this.addClass('active');
								$toggles.addClass('active');

							// Activate body.
								$body.addClass('content-active');

						})
						.on('---hide', function() {

							// Deactivate content, toggles.
								$this.removeClass('active');
								$toggles.removeClass('active');

							// Deactivate body.
								$body.removeClass('content-active');

						});

				// Toggles.
					$toggles
						.removeAttr('href')
						.css('cursor', 'pointer')
						.on('click', function(event) {

							event.preventDefault();
							event.stopPropagation();

							$this.trigger('---toggle');

						});

			});

			// Global events.
				$body
					.on('click', function(event) {

						if ($body.hasClass('content-active')) {

							event.preventDefault();
							event.stopPropagation();

							$panels.trigger('---hide');

						}

					});

				$window
					.on('keyup', function(event) {

						if (event.keyCode == 27
						&&	$body.hasClass('content-active')) {

							event.preventDefault();
							event.stopPropagation();

							$panels.trigger('---hide');

						}

					});

		// Header.
			var $header = $('#header');

			// Links.
				$header.find('a').each(function() {

					var $this = $(this),
						href = $this.attr('href');

					// Internal link? Skip.
						if (!href
						||	href.charAt(0) == '#')
							return;

					// Redirect on click.
						$this
							.removeAttr('href')
							.css('cursor', 'pointer')
							.on('click', function(event) {

								event.preventDefault();
								event.stopPropagation();

								window.location.href = href;

							});

				});
		// Main.
			var $main = $('#main');

			// Thumbs.
				$main.children('.thumb').each(function() {

					var	$this = $(this),
						$image = $this.find('.image'), $image_img = $image.children('img'),
						x;

					// No image? Bail.
						if ($image.length == 0)
							return;

					// Image.
					// This sets the background of the "image" <span> to the image pointed to by its child
					// <img> (which is then hidden). Gives us way more flexibility.

						// Set background.
							$image.css('background-image', 'url(' + $image_img.attr('src') + ')');

						// Set background position.
							if (x = $image_img.data('position'))
								$image.css('background-position', x);

						// Hide original img.
							$image_img.hide();



				});

			// Thumbs Index.
				$main.children('.thumb').each(function() {

					var	$this = $(this),
						$link = $this.find('.link'), $link_img = $link.children('img'),
						x;

					// No link? Bail.
						if ($link.length == 0)
							return;

					// link.
					// This sets the background of the "link" <span> to the link pointed to by its child
					// <img> (which is then hidden). Gives us way more flexibility.

						// Set background.
							$link.css('background-image', 'url(' + $link_img.attr('src') + ')');

						// Set background position.
							if (x = $link_img.data('position'))
								$link.css('background-position', x);

						// Hide original img.
							$link_img.hide();

				

				});
			

	});

})(jQuery);
