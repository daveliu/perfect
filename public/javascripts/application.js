function addLoadEvent(func) {

  var oldonload = window.onload;

  if (typeof window.onload != 'function') {

    window.onload = func;

  } else {

    window.onload = function() {

      oldonload();

      func();

    }

  }

}

var inputtext = function() {

  var inputs = document.getElementsByTagName('INPUT');

  for (var i = 0; i < inputs.length; i++) {

    var str = "form-control";

    if (str.indexOf(inputs[i].className) == -1) continue;

    var element = inputs[i];



    element.onfocus = function() {



      if (this.value == this.placeholder) {

        this.value = "";

        keyup(this);

      }

    }

    element.onblur = function() {

      if (this.value == "") {

        this.value = this.placeholder;

        keyup(this);

        this.value = "";

      }

    }



  }

}

addLoadEvent(inputtext);




function keyup(input)

{

  var id_str = input.id;

  var num = id_str[5];

  var text_id = "top-line" + num;

  var temp = input.value;

  if (input.value == "")

    temp = " &nbsp;";

  $("#" + text_id).html(temp);

}

var submit = false; 
var t;
function init_upload(){


  $("#upload_input").on('change', function(){
    submit = false; 
      
    var spin = '<div class="uploading-module" style="">    <p><img src="/images/indicator.gif" width="16" height="16">正在上传，请稍候...</p>  </div>';
    $(this).hide()
    $(spin).insertAfter($(this));

    $(this).parents('form').submit();
    return false;
  }) 
}

function upload_success(imgUrl, token){
  $('.pic-div img').attr('src', imgUrl).show();
  $('.uploading-module').remove();
  $('#upload_input').show();
  
//  clearTimeout(t);  
  init_upload();
  submit = true; 
  $("#createFrom input[name=token]").val(token);
  return false;
}

function upload_error(msg){
  alert(msg);
  $('.uploading-module').remove();
  $('#upload_input').show();
  
//  clearTimeout(t);
  init_upload();
  return false;  
}


$(document).ready(function() {

  $("input[type=text]").change(function() {

      keyup(this);

    });
  $('input[type=text]').on('input',function(){
      keyup(this);
  });
  
  init_upload();
  
  $("#submit-generate").click(function(){

    var result = true;
    $( "input[require=true]" ).each(function( index ) {
      if ($(this).val() == "") {
        alert('请填写有*标志的所有输入框')
        result = false
        return false;
      }
    });
    
    
    if (result) {
      // if (  $("#createFrom input[name=token]").val() == "") {
      //   alert('请上传照片')
      //   result = false
      //   return false;
      // }
      
      $(this).attr('disabled', true)
      $("#createFrom").submit();      
    }

    return false;
  })
  


});
