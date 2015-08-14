(function(){
	$(document).ready(function(){ 


		var current_user_id = $("#current_user_id").val()
		console.log(current_user_id)
	  var add_ingredients_block = '<div class="add-ingredient"> <hr><a class="close remove-new-ingredient"><i class="fa fa-times"></i></a> <div class="control-group"> <label class="control-label" for="inputEmail">ingredient name</label> <div class="controls"> <input class="span8" type="text" placeholder="ingredient name" name="ingredient[][name]" required></div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient standard measurement </label> <div class="controls"> <select name="ingredient[][std_measurement]"><option value="dz">dozen</option><option value="teaspoon">teaspoon</option> <option value="tablespoon">tablespoon</option> <option value="fluid ounce">ounce</option> <option value="gill">gill</option> <option value="cup">cup</option> <option value="pint">pint</option> <option value="quart">quart</option> <option value="gallon">gallon</option> <option value="ml">milli liter</option> <option value="l">liter</option> <option value="dl">deci liter</option> <option value="pounds">pounds</option> <option value="ounce">ounce</option> <option value="mg">mili grams</option> <option value="g">grams</option> <option value="kg">kilo grams</option> <option value="mm">mili meter</option> <option value="cm">centi meter</option> <option value="m">meter</option> <option value="inch">inch</option> </select> </div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient meal class </label> <div class="controls"> <select name="ingredient[][meal_class]"> <option value="jain">jain</option> <option value="veg">veg</option> <option value="non-veg">non-veg</option> </select> </div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient standard quantity</label> <div class="controls"> <input type="number" placeholder="example 10 grams" name="ingredient[][std_quantity]" required> </div> </div> <div class="control-group inline"> <label class="control-label" for="inputEmail">ingredient quantity</label> <div class="controls"> <input type="number" palceholder="e.g 1kg" name="ingredient[][quantity]" required> </div> </div> <div class="control-group"> <label class="control-label" for="inputEmail">calories per std qty</label> <div class="controls"> <input type="number" name="ingredient[][calories_per_quantity]" required> </div> </div> </div>'
	    
	  var existing_ingredient_block = '<div class="control-group added-ingredient"><label class="control-label" for="ingredients">ingredient_name</label> <a class="close remove-added-ingredien"><i class="fa fa-times"></i></a> <div class="controls"> <input type="hidden" name="existing_ingredient[][ingredient_id]" value="ingredient_id_will_come_here">  <input type="hidden" name="existing_ingredient[][meal_class]" value="ingredient_meal_class"> <input type="hidden" name="existing_ingredient[][std_quantity]" value="ingredient_std_quantity"> <input type="hidden" name="existing_ingredient[][calories_per_quantity]" value="ingredient_calories_per_quantity"> <div class="input-append"> <input placeholder="add-quantity" type="number" name="existing_ingredient[][quantity]" required><span class="add-on">ingredient_std_measurement</span> </div></div> </div>'
	   
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

	  	// $('.chosen-select').chosen()
	  	
	  

	    $('#add-ingredient').on('click',function(e){
	    	e.preventDefault()
	      $('.ingredients-container').append(add_ingredients_block)
	    })
		
	   $('.ingredients-container').on("click", '.remove-new-ingredient',function(e){
	   		 e.preventDefault()
	   		$(this).closest('.add-ingredient').remove()
	   })

	   $('#existing-ingredient-block').on('click','.remove-added-ingredient', function(){
	   		alert('hi')
	   		$(this).closest('.added-ingredient').remove()
	   })


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
   		 			console.log($(this))
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
   						console.log(data.message);
   					}
   				});
	   		}
	   	});



	   $('.ingredients-container').on('click','.remove-existing-ingredient', function(event){
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
 	   				$this.closest('.existing-ingredient').remove() 
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

	    // @@TODO use plugins for all the codes doen here which are almost repeating

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
				 	  $('#display-notice-message').html("<div class='alert alert-success text-center'>recipe approved successfully</div>")
			 	  }
			 	  else
			 	  {
				 	  $('#display-notice-message').html("<div class='alert alert-danger text-center'> resipe approval error</div>")
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
				 	  $('#display-notice-message').html("<div class='alert alert-success text-center'>recipe rejected successfully</div>")
			 	  }
			 	  else
			 	  {
				 	  $('#display-notice-message').html("<div class='alert alert-danger text-center'>recipe reject error</div>")
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
		  

		 // $('.trigger-process-queue').click(function(){
		 // 		$('.dropzone').dropzone({processQueue: true})
		 // })

		 
		//  Dropzone.autoDiscover = false;
		//   // earlier code using form element drag and drop
		//  $(".dropzone").dropzone({
		//  	maxFilesize: 1,
		//  	dictDefaultMessage: "Drop files to create recipe album",
		//  	dictFallbackMessage: "Your browser is not supported please upgrade or you are missing in some functionality ",
		//  	paramName: "file",
		//  	addRemoveLinks: true,
		//  	autoProcessQueue: true,
		//  	success: function(file, response){		 
		//  		$(file.previewTemplate).find('.dz-remove').attr('id', response.object.id);
		//  		$(file.previewElement).addClass("dz-success");
		//  		var photo_id = []
		//  		$('.dz-success').each(function(){
		//  			console.log($(this))
		//  			photo_id.push($(this).find('.dz-remove').attr('id')) 
		//  		})
		//  		photo_id_array = JSON.stringify(photo_id)
		//  		$('#add-photo-array').val(photo_id_array)
		//  	},
		//  	removedfile: function(file){
		// 		var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
		// 	 	$(file.previewTemplate).find('.dz-remove').parent().remove()
		// 		$.ajax({
		// 			type: 'DELETE',
		// 			url: '/photos/' + id,
		// 			success: function(data){
		// 				console.log(data.message);
		// 			}
		// 	});
		// }
		//  });	
		  
	  	select = $(".chosen-select");
    	select.chosen();
    	chosen = select.data('chosen').container;
    	chosen.bind('keypress', function(e){
    		if(e.keyCode==13)
    		{
  			 	values = $('#existing-ingredient-list').val()
  					var add_block_existing_recipes =  ""
  			 	$.each(values, function(index, ing_id){
  			 		ing = ing_id.split("-")
  			 		string = existing_ingredient_block
  			 		string = string.replace('ingredient_id_will_come_here', ing[0])
  			 		string = string.replace('ingredient_name', ing[1])
  			 		string = string.replace('ingredient_meal_class', ing[2])
  			 		string = string.replace('ingredient_std_quantity', ing[3])
  			 		string = string.replace('ingredient_calories_per_quantity', ing[4])
  			 		string = string.replace('ingredient_std_measurement', ing[5])
  			 		add_block_existing_recipes += string
  			 	})
  			 	  $('#existing-ingredient-block').html(add_block_existing_recipes)
    		}
    	})

 
	})  





}).call(this);