$(document).ready(function() {
    console.log("rviz");

    /* Code highlighting menu */
    jsToolBar.prototype.precodeMenu = function(fn){
    var hlLanguages = ["c", "cpp", "csharp", "css", "diff", "go", "graphviz", "groovy", "html", "java", "javascript", "objc", "perl", "php", "python", "r", "ruby", "sass", "scala", "shell", "sql", "swift", "xml", "yaml"];
    var menu = $("<ul style='position:absolute;'></ul>");
    for (var i = 0; i < hlLanguages.length; i++) {
        $("<li></li>").text(hlLanguages[i]).appendTo(menu).mousedown(function(){
        fn($(this).text());
        });
    }
    $("body").append(menu);
    menu.menu().width(150).position({
        my: "left top",
        at: "left bottom",
        of: this.toolNodes['precode']
    });
    $(document).on("mousedown", function() {
        menu.remove();
    });
    return false;
    };

});

