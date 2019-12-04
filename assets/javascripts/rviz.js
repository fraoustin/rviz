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

    if (document.querySelectorAll('.graphviz').length > 0) {
        var script = document.createElement("script")
        script.src = '/plugin_assets/rviz/javascripts/viz.js'
        script.onload = function(){
            Array.from(document.querySelectorAll('.graphviz')).forEach(elt => {
                var engine = 'dot';
                if (elt.classList.contains('circo')) { engine = 'circo';}
                if (elt.classList.contains('fdp')) { engine = 'fdp';}
                if (elt.classList.contains('neato')) { engine = 'neato';}
                if (elt.classList.contains('osage')) { engine = 'osage';}
                if (elt.classList.contains('twopi')) { engine = 'twopi';}
                    
                var code = elt.innerText;
                if (code.indexOf("digraph") == -1) {
                    code = graphviz_head + code + graphviz_foot; 
                }
                img= Viz(code, {'format':'png-image-element','engine':engine})
                elt.parentNode.insertBefore(img, elt);
            });
        }
        document.head.appendChild(script)
    }

});

