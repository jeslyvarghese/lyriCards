  var sq = new selection_queue('lyric_line');
  $(document).ready(function(){
      $("#loading").hide();
      $("#show_lyric_btn").hide();
      $("#make-card").hide();
      var options = { 
       // target element(s) to be updated with server response 
        beforeSubmit:  showRequest,  // pre-submit callback 
        success:       showResponse,  // post-submit callback 
 
        // other available options: 
        url: 'select', // override for form's 'action' attribute 
        //type:      type        // 'get' or 'post', override for form's 'method' attribute 
        dataType:  'json',
        data:{query: function(){
               return $("#search_songs").data("kendoAutoComplete").value();
              }}        // 'xml', 'script', or 'json' (expected server response type) 
        //clearForm: true        // clear all form fields after successful submit 
        //resetForm: true        // reset the form after successful submit 
        // $.ajax options can be used here too, for example: 
        //timeout:   3000 
    };

    });
    $("#search_form").ajaxForm(options);
    $("#search_songs").focus(function(){this.value=""});
    $("#search_songs").blur(function(){if(this.value=="")this.value="Search for your favourite music"});
    $("#search_songs").kendoAutoComplete({
          minLength:50,
          dataTextField:"name",
          filter: "contains",
          dataSource: new kendo.data.DataSource({
           dataType: "json",
           transport: {
            read: {
             url: "/songs",
             data: {
              query: function(){
               return $("#search_songs").data("kendoAutoComplete").value();
              }
             }
            }
           },
          }),
          change: function(){
           this.dataSource.read();
          },
          select: function(e){
          setTimeout(function(){$("#search_form").submit();},100);
          }
         });

     $("#loading").ajaxStart(function() {
        $("#bring-lyrics").attr("disabled",true);
        $("#search_songs").attr("disabled",true);
        $("#bring-lyrics").html("<img src='/images/busy.gif'/>");
        })
      $("#loading").ajaxStop(function() {
        $("#bring-lyrics").removeAttr("disabled");
        $("#search_songs").removeAttr("disabled");
        $("#bring-lyrics").html("Choose Another!!");
        })
     });
  function showResponse(responseText, statusText){
                    $("#search_songs").removeAttr("disabled");
                if(statusText=='success'){
                     $("#loading").hide();
                     $("#result_grid").show();
                     $("#result_grid").kendoGrid({
                        dataSource: {
                            dataType: "json",
                            data:responseText,
                            schema: {
                                model: {
                                    fields: {
                                        track_id: {type: "string"},
                                        track_name: { type: "string" },
                                        artist_name: { type: "string" },
                                        album_name: { type: "string" },
                                        }
                                }
                            },
                            serverPaging: true,
                            serverFiltering: true,
                            serverSorting: true,
                        },
                        height: 500,
                        filterable: false,
                        pageable: false, 
                        sortable: true,
                        scrollable: true,
                        selectable: "single",
                        navigationable: false,
                        change: function(){
                        var record = this.dataSource.getByUid(this.select().data("uid"));
                        $("#show_lyric_btn").show();
                        $("#bring-lyrics").html('Bring me lyrics of '+record.track_name);
                        $("#bring-lyrics").attr("track_id",record.track_id);
                        },
                        columns: [
                                  { 
                                    field:"artist_name",
                                    title:"Artist"
                                    },
                                  {
                                    title:"Track",
                                    field:"track_name"
                                    },
                                  {
                                    title:"Album",
                                    field:"album_name"
                                    }]
                    });}
      else
          {
            $("#loading").show().html("Sorry dear, we couldn't get you anything. Give one more try."+statusText);
          }
  }
  function showRequest(formData, jqForm, options) {

      $("#result_grid").hide();
      $("#show_lyric_btn").hide();
      $("#search_songs").attr("disabled",true);
      $("#loading").html("Looking for "+$("#search_songs").data("kendoAutoComplete").value()+"...."+"<img src='/images/busy.gif'/>").show();
    }
  function load_lyrics()
  { var id = $("#bring-lyrics").attr("track_id"); 
    $(document).ready(function(){
     
      $.ajax({
        type: "post",
        url: "/select/get_lyrics",
        data: {track_id:id},
        dataType: "html",
      }).done(function(data){
          $("#lyric_selector").show();
          $("#lyric_contents").html(data);
          $("#bring-lyrics").removeAttr("disabled").html("Choose another");

      });
    });
  }
