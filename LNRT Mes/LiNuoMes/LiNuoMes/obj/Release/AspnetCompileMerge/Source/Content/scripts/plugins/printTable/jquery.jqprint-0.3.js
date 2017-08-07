// -----------------------------------------------------------------------
// Eros Fratini - eros@recoding.it
// jqprint 0.3
//
// - 19/06/2009 - some new implementations, added Opera support
// - 11/05/2009 - first sketch
//
// Printing plug-in for jQuery, evolution of jPrintArea: http://plugins.jquery.com/project/jPrintArea
// requires jQuery 1.3.x
//
// Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
//------------------------------------------------------------------------

(function($) {
    var opt;

    $.fn.jqprint = function (options) {
        opt = $.extend({}, $.fn.jqprint.defaults, options);

        var $element = (this instanceof jQuery) ? this : $(this);
        
        if (opt.operaSupport && $.browser.opera) 
        { 
            var tab = window.open("","jqPrint-preview");
            tab.document.open();

            var doc = tab.document;
        }
        else 
        {
            var $iframe = $("<iframe  />");
        
            if (!opt.debug) { $iframe.css({ position: "absolute", width: "0px", height: "0px", left: "-600px", top: "-600px" }); }

            $iframe.appendTo("body");
            var doc = $iframe[0].contentWindow.document;
        }

        var _self = $(this).clone(), timer, firstCall, win, $html = $(html);
        if (opt.table) {
            var $printArea = _self.find('.printArea');
            alert($printArea);
            $.each($printArea, function (i, item) {
                var $_area = $(item)
                if ($_area.find('.ui-jqgrid').length == 0) {
                    var $tb = $_area.find("table.form").eq(0).clone().removeAttr("style").attr("class", "ui-table-print");
                    $tb.find("th").css("width", "auto");
                    //$tb.find("td").css("width", "auto");

                    $(win.document.body).append($tb);
                } else {
                    var $tb = $_area.find("table.ui-jqgrid-htable").eq(0).clone().removeAttr("style").attr("class", "ui-table-print");
                    var $data = $_area.find("table.ui-jqgrid-btable").eq(0).find("tbody").clone();
                    var $title = $_area.find("div.grid-title");
                    var $subtitle = $_area.find("div.grid-subtitle");
                    var $summary = $_area.find("table.ui-jqgrid-ftable").find("tbody").clone();

                    if ($title.length) {
                        $('<caption/>').prependTo($tb).append($title.clone()).append($subtitle.clone());
                    }
                    $tb.find("th").css("width", "auto");
                    $summary.find("td").css("width", "auto");
                    $data.children().eq(0).remove();
                    $tb.append($data).append($summary);
                    $(win.document.body).append($html).append($tb);
                }
            });
        
        }
        
        if (opt.importCSS)
        {
            if ($("link[media=print]").length > 0) 
            {
                $("link[media=print]").each( function() {
                    doc.write("<link type='text/css' rel='stylesheet' href='" + $(this).attr("href") + "' media='print' />");
                });
            }
            else 
            {
                $("link").each( function() {
                    doc.write("<link type='text/css' rel='stylesheet' href='" + $(this).attr("href") + "' />");
                });
            }
        }
      

        if (opt.printContainer) { doc.write($element.outer()); }
        else { $element.each( function() { doc.write($(this).html()); }); }
        
        doc.close();
        
        (opt.operaSupport && $.browser.opera ? tab : $iframe[0].contentWindow).focus();
        setTimeout( function() { (opt.operaSupport && $.browser.opera ? tab : $iframe[0].contentWindow).print(); if (tab) { tab.close(); } }, 3000);
    }
    
    $.fn.jqprint.defaults = {
		debug: false,
		importCSS: true, 
		printContainer: true,
		operaSupport: true,
		table:true
	};

    // Thanks to 9__, found at http://users.livejournal.com/9__/380664.html
    jQuery.fn.outer = function() {
      return $($('<div></div>').html(this.clone())).html();
    } 
})(jQuery);