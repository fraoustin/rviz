var graphviz_head = `
digraph G {
  edge [headlabel=" ", label=" ", taillabel=" "];
  node [style="rounded", shape=record];
  bgcolor="#FFFFFF";
  ratio=auto;
  compound=true;
`;
var graphviz_foot = `
}
`;

$(document).ready(function() {
    console.log("rviz");

    /* Code highlighting menu */
    if( typeof(jsToolBar) != 'undefined' ) {
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
    };

    if (document.querySelectorAll('.graphviz').length > 0) {
        var script = document.createElement("script")
        script.src = '/plugin_assets/rviz/javascripts/viz.js'
        script.onload = function(){
            Array.from(document.querySelectorAll('.graphviz')).forEach(elt => {
            var code = elt.innerText;
            if (code.indexOf("digraph") == -1) {
                code = graphviz_head + code + graphviz_foot; 
            }
            img= Viz(code, {'format':'png-image-element'})
            elt.parentNode.insertBefore(img, elt);
            });
        }
        document.head.appendChild(script)
    }

});

