(function(){
	$(document).ready(function(){ 

		var current_user_id = $("#current_user_id").val()
		console.log(current_user_id)
	  var add_ingredients_block = '<div class="add-ingredient"> <hr><a class="close remove-ingredient"> &times;</a> <div class="control-group"> <label class="control-label" for="inputEmail">ingredient name</label> <div class="controls"><input type="hidden" name="ingredient[][id]" value=""> <input class="span8" type="text" placeholder="ingredient name" name="ingredient[][name]" required></div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient standard measurement </label> <div class="controls"> <select name="ingredient[][std_measurement]"><option value="dz">dozen</option><option value="teaspoon">teaspoon</option> <option value="tablespoon">tablespoon</option> <option value="fluid ounce">ounce</option> <option value="gill">gill</option> <option value="cup">cup</option> <option value="pint">pint</option> <option value="quart">quart</option> <option value="gallon">gallon</option> <option value="ml">milli liter</option> <option value="l">liter</option> <option value="dl">deci liter</option> <option value="pounds">pounds</option> <option value="ounce">ounce</option> <option value="mg">mili grams</option> <option value="g">grams</option> <option value="kg">kilo grams</option> <option value="mm">mili meter</option> <option value="cm">centi meter</option> <option value="m">meter</option> <option value="inch">inch</option> </select> </div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient meal class </label> <div class="controls"> <select name="ingredient[][meal_class]"> <option value="jain">jain</option> <option value="veg">veg</option> <option value="non-veg">non-veg</option> </select> </div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient standard quantity</label> <div class="controls"> <input type="number" step="0.01" placeholder="example 10 grams" name="ingredient[][std_quantity]" required> </div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient quantity</label> <div class="controls"> <input type="number" step="0.01" palceholder="e.g 1kg" name="ingredient[][quantity]" required> </div> </div> <div class="control-group"> <label class="control-label" for="inputEmail">calories per std qty</label> <div class="controls"> <input step="0.01" type="number" name="ingredient[][calories_per_quantity]" required> </div> </div> </div>'
	    
	  var existing_ingredient_block = '<div class="add-ingredient"> <div class="control-group"><label class="control-label" for="ingredients">ingredient_name</label> <a class="close remove-ingredient" data-value="data_value">&times;</a> <div class="controls"> <input type="hidden" name="ingredient[][id]" value="ingredient_id_will_come_here">  <input type="hidden" name="ingredient[][meal_class]" value="ingredient_meal_class"> <input type="hidden" name="ingredient[][name]" value="ingredient_name"> <input type="hidden" name="ingredient[][std_measurement]" value="ingredient_std_measurement"><input type="hidden" name="ingredient[][std_quantity]" value="ingredient_std_quantity"> <input type="hidden" name="ingredient[][calories_per_quantity]" value="ingredient_calories_per_quantity"> <div class="input-append"> <input placeholder="add-quantity" type="number" step="0.01" name="ingredient[][quantity]" required><span class="add-on">ingredient_std_measurement</span> </div></div> </div></div>'
	   
  	$('#recipe-description').wysihtml5();
  	$('.glyphicon.glyphicon-font').addClass('fa fa-font');
  	$('.fa.fa-font').removeClass('glyphicon glyphicon-font');
  	$('.glyphicon.glyphicon-list').addClass('fa fa-list');
  	$('.fa.fa-list').removeClass('glyphicon glyphicon-list');
  	$('.glyphicon.glyphicon-th-list').addClass('fa fa-th-list');
  	$('.fa.fa-th-list').removeClass('glyphicon glyphicon-th-list');
  	$('.glyphicon.glyphicon-indent-right').addClass('fa fa-dedent');
  	$('.fa.fa-dedent').removeClass('glyphicon glyphicon-indent-right');
  	$('.glyphicon.glyphicon-quote').addClass('fa fa-quote-left');
  	$('.fa.fa-quote-left').removeClass('glyphicon glyphicon-quote');
  	$('.glyphicon.glyphicon-indent-left').addClass('fa fa-indent');
  	$('.fa.fa-indent').removeClass('glyphicon glyphicon-indent-left');
  	$('.glyphicon.glyphicon-share').addClass('fa fa-link');
  	$('.fa.fa-link').removeClass('glyphicon glyphicon-share');
  	$('.glyphicon.glyphicon-picture').addClass('fa fa-file-image-o');
  	$('.fa.fa-file-image-o').removeClass('glyphicon glyphicon-picture');

	  $('#add-ingredient').on('click',function(e){
	    	e.preventDefault()
	      $('.ingredients-container').append(add_ingredients_block)
	  })
	
	  $('.ingredients-container').on('click', '.remove-ingredient', function(e){
	   		e.preventDefault
	   		existing = $(this).data('existing')
	   		$this = $(this)
	   		if(existing == true)
	   		{
		   		var recipe_ingredient = {"recipe_id" : $(this).data('rec-id'), "ingredient_id" : $(this).data('ing-id')}

		   		 console.log(recipe_ingredient)
		    	$.ajax({
		    		url : "/recipes/destroy_ingredient",
		    		method : 'DELETE',
		    		data: {recipe_ingredient: recipe_ingredient},
		    		dataType : "json"
		    	})
		    	 .done(function(response, textStatus, jqXHR) { 
		    	 		data_value = $this.data('value')
		   				$('.chosen-select').find('option[value="' +data_value+ '"]').prop('selected', false).end().trigger('chosen:updated');
		   				$this.closest('.add-ingredient').remove() 
	    	 	  	 
	    	 	  	console.log('successfully removed')
		    	 })
		    	 .fail(function() {
		    	    // alert( "error" );
		    	 })
	   		}
	   		else
	   		{
	   			data_value = $(this).data('value')
	   			$('.chosen-select').find('option[value="' +data_value+ '"]').prop('selected', false).end().trigger('chosen:updated');
	   			$(this).closest('.add-ingredient').remove()
	   		}
	  })

	  $('.ingredients-container').on('click','.remove-my-existing-ingredient', function(event){
	   		$this = $(this)
	   		var recipe_ingredient = {"recipe_id" : $(this).data('rec-id'), "ingredient_id" : $(this).data('ing-id')}
	   		console.log(recipe_ingredient)
	    	$.ajax({
	    		url : "/recipes/destroy_ingredient",
	    		method : 'DELETE',
	    		data: {recipe_ingredient: recipe_ingredient},
	    		dataType : "json"
	    	})
	    	 .done(function(response, textStatus, jqXHR) { 
	   				$this.closest('.my-existing-ingredient').remove() 
	 	 	  	console.log(response)
	 	 	  	console.log('successfully deleted')
	    	 })
	    	 .fail(function() {
	    	    // alert( "error" );
	    	 })
	  })

	  $('.add-photo').click(function(){
			recipe_id =  $(this).data('rec-id')
			$('#modal-recipe-id').val(recipe_id)
			$('#photo-upload-modal').modal('toggle')
		})

    $('.star-rate').click(function(){
    	var recipe = {"id" : $(this).closest('.star-rating').data('rec-id'), "ratings" : $(this).data('star-rate')}
    	 	$('.spinner').css('display', 'block')
    	 	$('.star-rating').css('display', 'none')
    	$.ajax({
    		url : "/recipes/rate",
    		method : 'POST',
    		data: {recipe: recipe},
    		dataType : "json"
    	})
    	 .done(function(response, textStatus, jqXHR) { 
  	 	  	$('.spinner').css('display','none')
  	 	 		$('.rate-recipe').css('display','none')
  	 	  	 console.log(response)
  	 	  	$('.notice-message').html(response.message)
    	 })
    	 .fail(function() {
    	    // alert( "error" );
    	 })
    	 .always(function() {
    	    // alert( "complete" );
    	 });
    })

    $('.dropdown-menu').click(function(event){
         event.stopPropagation()})
    $('.ingredient-link,.meal_class-link').hover(function(){
    	$(this).tooltip('toggle')
    })

		$('.approve-recipe').click(function(e){
			e.preventDefault() 
			var $this = $(this)
			rec_id = $(this).data('rec-id')
			var recipe = {"approved" : true, "id" : rec_id}
	 		$(this).closest('.approve-reject-block').css('display','none')
	 		$(this).closest('.approve-reject-block').siblings('.spin-block').css('display','block')
			 console.log(recipe)
			$.ajax({
				url : "/recipes/approve_recipe",
				method : 'PUT',
				data: {recipe: recipe},
				dataType : "json"
			})
			 .done(function(recipe_object, textStatus, jqXHR) {
			 	  if (recipe_object.approved == true)
			 	  {
				 	  $this.closest(".span6").hide()
				 	  // $('#display-notice-message').html("<div class='alert alert-success text-center'>recipe approved successfully</div>")
				 	  $('.approve-reject-block').css('display','block')
				 	  $this.closest('.approve-reject-block').siblings('.spin-block').css('display','none')
				 	  $this.closest('.approve-reject-block').html('<i class="fa fa-check"></i> approved')
			 	  }
			 	  else
			 	  {
				 	  $this.closest('.approve-reject-block').html('<i class="fa fa-exclamation-triangle"></i> some error occured')
			 	  }
			 	  console.log(recipe_object)
			 })
			 .fail(function() {
			    // alert( "error" );
			 })
			 .always(function() {
			    // alert( "complete" );
			 });
			return false
		})
		
		$('.reject-recipe').click(function(e){
			e.preventDefault() 
			rec_id = $(this).data('rec-id')
			var recipe = {"rejected" : true, "id" : rec_id}
			$(this).closest('.approve-reject-block').css('display','none')
			$(this).closest('.approve-reject-block').siblings('.spin-block').css('display','block')
			var $this = $(this)
			$.ajax({
				url : "/recipes/reject_recipe",
				method : 'PUT',
				data: {recipe: recipe},
				dataType : "json"
			})
			 .done(function(recipe_object, textStatus, jqXHR) {
			 	 if (recipe_object.rejected == true)
			 	  {
				 	  $this.closest(".span6").hide()
				 	  // $('#display-notice-message').html("<div class='alert alert-success text-center'>recipe rejected successfully</div>")
				 	  $('.approve-reject-block').css('display','block')
				 	  $this.closest('.approve-reject-block').siblings('.spin-block').css('display','none')
				 	  $this.closest('.approve-reject-block').html('<i class="fa fa-check"></i> rejected')
			 	  }
			 	  else
			 	  {
				 	 $this.closest('.approve-reject-block').html('<i class="fa fa-exclamation-triangle"></i> some error occured')
			 	  }
			 })
			 .fail(function() {
			    // alert( "error" );
			 })
			 .always(function() {
			    // alert( "complete" );
			 });
			return false
		})

		$('.rate-recipe').click(function(){
			recipe_id =  $(this).data('rec-id')
			$('#modal-recipe-id').val(recipe_id)
			$('#rate-modal').modal('toggle')
		})

		$('.bar span').hide();
	  $('#bar-five').animate({
	     width: '75%'}, 1000);
	  $('#bar-four').animate({
	     width: '35%'}, 1000);
	  $('#bar-three').animate({
	     width: '20%'}, 1000);
	  $('#bar-two').animate({
	     width: '15%'}, 1000);
	  $('#bar-one').animate({
	     width: '30%'}, 1000);
		  
	  setTimeout(function() {
	    $('.bar span').fadeIn('slow');
	  }, 1000);
		  	
		function make_add_ingredient_html (ing) {
    	var string = existing_ingredient_block  
    	string = string.replace('data_value', ing)
    	ing = ing.split('-'); 
	    string = string.replace('ingredient_id_will_come_here', ing[0])
  	  string = string.replace(/ingredient_name/g, ing[1])
  	  string = string.replace('ingredient_meal_class', ing[2])
  	  string = string.replace('ingredient_std_quantity', ing[3])
  	  string = string.replace('ingredient_calories_per_quantity', ing[4])
  	  string = string.replace(/ingredient_std_measurement/g, ing[5])
    	return string
		}
 
  	$(".chosen-select").chosen().change(function(e, params) {
  		 console.log(params)
  		var id;
  		 
  		e.preventDefault
  		if ('deselected' in params) 
  			{
  				data_value = params.deselected;
  				console.log(data_value)
  				$('.ingredients-container').find('[data-value="' + data_value + '"]').closest('.add-ingredient').remove();
  				$(".chosen-select").trigger('chosen:updated');
  			};

  		if ('selected' in params) {
  	  	var ing = params.selected;
    	  $('.ingredients-container').prepend(make_add_ingredient_html(ing))  
    	  $(".chosen-select").trigger('chosen:updated');
  		};
  	});
		
		var myDropzone = new Dropzone("div#imageUpload", { 
			url: "/photos",
			maxFilesize: 1,
			dictDefaultMessage: "Drop files to create recipe album",
			dictFallbackMessage: "Your browser is not supported please upgrade or you are missing in some functionality ",
		 	paramName: "file",
		 	// show remove links on each image upload
		 	addRemoveLinks: true,
		 	autoProcessQueue: true,
		 	success: function(file, response){		 
		 		$(file.previewTemplate).find('.dz-remove').attr('id', response.object.id);
		 		$(file.previewElement).addClass("dz-success");
		 		var photo_id = []
		 		$('.dz-success').each(function(){
		 			// console.log($(this))
		 			photo_id.push($(this).find('.dz-remove').attr('id')) 
		 		})
		 		photo_id_array = JSON.stringify(photo_id)
		 		$('#add-photo-array').val(photo_id_array)
		 	},
		 	removedfile: function(file){
				var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
			 	$(file.previewTemplate).find('.dz-remove').parent().remove()
				$.ajax({
					type: 'DELETE',
					url: '/photos/' + id,
					success: function(data){
						// console.log(data.message);
					}
				});
			}
		});
	})  
}).call(this);