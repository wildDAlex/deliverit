/**
 * Created by wilddalex on 14.12.14.
 * more about tagsinput at http://timschlechter.github.io/bootstrap-tagsinput/examples/bootstrap-2.3.2.html
 */

$(document).ready(function () {

    var elem = $('input#share_tag_list');
    var form_id = elem.data('share-form-id');


    $('input#share_tag_list').on('itemAdded', function(event) {
        $('form#'+form_id).trigger('submit.rails');
    });

    $('input#share_tag_list').on('itemRemoved', function(event) {
        $('form#'+form_id).trigger('submit.rails');
    });

    $('input#share_tag_list').tagsinput({
        trimValue: true,
        tagClass: 'label label-warning'
    });

});

