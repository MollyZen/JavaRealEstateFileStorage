var map;
var vectorSource;
var timer, timeoutVal = 1000; //ms
function addMap(){
    const layers = [
        new ol.layer.Tile({
            source: new ol.source.OSM()
        }),
        new ol.layer.Tile({
            source: new ol.source.TileWMS({
                url: 'https://pkk.rosreestr.ru/arcgis/rest/services/PKK6/CadastreOriginal/MapServer/export',
                params: {	
                    layers: "show:0",
                    dpi:96,
                    format: "png32",
                    f:"image",
                    transparent: true,
                    bboxSR:102100,
                    imageSR:102100,
                    size:"1024,1024"
                },
                serverType: 'mapserver',
                tileGrid:new ol.tilegrid.TileGrid({tileSize: [1024, 1024],extent: ol.proj.get('EPSG:3857').getExtent(),resolutions:[ 9.554, 4.777, 2.388, 1.194, 0.597, 0.298, 0.149, 0.074]})
            }),
            minZoom: 14
        }),
        new ol.layer.Tile({
            source: new ol.source.TileWMS({
                url: 'https://pkk.rosreestr.ru/arcgis/rest/services/PKK6/CadastreOriginal/MapServer/export',
                params: {	
                    layers: "show:2",
                    dpi:96,
                    format: "png32",
                    f:"image",
                    transparent: true,
                    bboxSR:102100,
                    imageSR:102100,
                    size:"1024,1024"
                },
                serverType: 'mapserver',
                tileGrid:new ol.tilegrid.TileGrid({tileSize: [1024, 1024],extent: ol.proj.get('EPSG:3857').getExtent(),resolutions:[ 9.554, 4.777, 2.388, 1.194, 0.597, 0.298, 0.149, 0.074]})
            }),
            minZoom: 14
        })
    ];
    
    class HideLayer extends ol.control.Control{
        constructor(opt_options){
            const options = opt_options || {};
            
            const div0 = document.createElement('div');
            
            const check0 = document.createElement('input');
            check0.setAttribute('type', 'checkbox');
            check0.setAttribute('id', 'check0');
            check0.setAttribute('name', 'Карта');
            check0.checked = true;
            
            const label0 = document.createElement('label');
            label0.setAttribute('for', 'check0');
            label0.innerHTML = 'Карта';
            
            div0.appendChild(label0);
            div0.appendChild(check0);
            div0.style.float = 'right';
            
            const div1 = document.createElement('div');
            
            const check1 = document.createElement('input');
            check1.setAttribute('type', 'checkbox');
            check1.setAttribute('id', 'check1');
            check1.setAttribute('name', 'Земельные участки');
            check1.checked = true;
            
            const label1 = document.createElement('label');
            label1.setAttribute('for', 'check1');
            label1.innerHTML = 'Земельные участки';
            
            div1.appendChild(label1);
            div1.appendChild(check1);
            div1.style.float = 'right';
            
            const div2 = document.createElement('div');
            
            const check2 = document.createElement('input');
            check2.setAttribute('type', 'checkbox');
            check2.setAttribute('id', 'check2');
            check2.setAttribute('name', 'ОКС');
            check2.checked = true;
            
            const label2 = document.createElement('label');
            label2.setAttribute('for', 'check2');
            label2.innerHTML = 'ОКС';
            
            div2.appendChild(label2);
            div2.appendChild(check2);
            div2.style.float = 'right';
            
            const element = document.createElement('div');
            element.className = 'layer-control ol-unselectable ol-control';
            element.style.right = '0px';
            element.style.left = 'unset';
            element.appendChild(div0);
            element.appendChild(div1);
            element.appendChild(div2);
            
            super({
                element: element,
                target: options.target
            });
            
            check0.addEventListener('change', function(){
                layers[0].setVisible(this.checked);
            });
            
            check1.addEventListener('change', function(){
                layers[1].setVisible(this.checked);
            });
            check2.addEventListener('change', function(){
                layers[2].setVisible(this.checked);
            });
        }
    }
    
    map = new ol.Map({
        layers: layers,
        target: 'map',
        view: new ol.View({
            center: [3373565.492065, 8381480.717088],
            zoom: 12
        }),
        controls: ol.control.defaults({
            zoom: true,
            attribution: false,
            rotate: false
        }).extend([new HideLayer()])
    });
    vectorSource = new ol.source.Vector({});
    const markersLayer = new ol.layer.Vector({
        source: vectorSource,
        style: new ol.style.Style({
            image: new ol.style.Icon({
                src:'/marker.png',
                anchor: [0.5, 1],
                scale: 0.25
            })
        })
    });
    map.addLayer(markersLayer);
    
}
function reverseGeocode(coords) {
    fetch('https://pkk.rosreestr.ru/api/features/?text=' + coords[1] + '+' + coords[0] + '&tolerance=16&types=[1]')
            .then(function(response) {
                return response.json();
    }).then(function(json) {
        if(Object.keys(json.results).length!==0){
            document.getElementById("faddr").value = json['results'][0].attrs.address;
            document.getElementById("fcad").value = json['results'][0].attrs.id;
        }
        else{
            getAddress(coords);
        }
    });
}
function getAddress(coords){
    fetch('/api/location?long=' + coords[0] + '&lat=' + coords[1])
            .then(function(response) {
                return response.json();
    }).then(function(json) {
        document.getElementById("faddr").value = json.addr;
        document.getElementById("fcad").value = "";
    });
}
function removeMarker(){
    vectorSource.clear();
}
function addMarker(coords){
    var marker = new ol.Feature({
        geometry: new ol.geom.Point(coords),
        name: "Marker"
    });
    vectorSource.addFeature(marker);
}
function addClickListener(){
    map.on('singleclick', function(evt){
        removeMarker();
        addMarker(evt.coordinate);
        var coord = ol.proj.toLonLat(evt.coordinate);
        reverseGeocode(coord);
    });
}
function addAddrAdjuster(){
    const typer = document.getElementById('faddr');
    typer.addEventListener('keypress',function(e){
        window.clearTimeout(timer);
    });
    typer.addEventListener('keyup',function(e){
       window.clearTimeout(timer);
       timer = window.setTimeout(()=>{
           fetch('../api/LonLat?addr='+typer.value)
                .then(function(response){
                    return response.json();
        }).then(function(json){
            var lat = json.lat;
            var lon = json.long;
            adjustMap([lon,lat]);
        });
       }, timeoutVal);
    });
}
function adjustMapNoCoords(){
    removeMarker();
    var addr = document.getElementById("faddr").value;
    if (addr === undefined){
        addr = document.getElementById("faddr").innerHTML;
    }
    addr = addr.replace(/ /g,"+");
    fetch('/api/LonLat?addr='+addr)
            .then(function(response){
                return response.json();
    }).then(function(json){
        var lat = json.lat;
        var lon = json.long;
        adjustMap([lon,lat]);
        addMarker(ol.proj.fromLonLat([lon,lat]));
    });
}
function adjustMap(coords){
    removeMarker();
    addMarker(ol.proj.fromLonLat([coords[0],coords[1]]));
    map.getView().animate({zoom: 15, center: ol.proj.fromLonLat([coords[0],coords[1]])});
}
function fillAddress(){
    var cad = document.getElementById("fcad").value;
    fetch("https://pkk.rosreestr.ru/api/features/1?text="+cad+"&limit=1&skip=0&tolerance=8")
            .then(function(response){
                return response.json();
    }).then(function(json){
        document.getElementById("faddr").value = json['features'][0].attrs.address; 
        var addr = json['features'][0].attrs.address;
        addr = addr.replace(/ /g,"+");
        fetch('/api/LonLat?addr='+addr)
                .then(function(response){
                    return response.json();
        }).then(function(json){
            var lat = json.lat;
            var lon = json.long;
            adjustMap([lon,lat]);
        });
    });
}
function fillCadastre(){
    var addr = document.getElementById("faddr").value;
    addr = addr.replace(/ /g,"+");
    fetch('/api/LonLat?addr='+addr)
            .then(function(response){
                return response.json();
    }).then(function(json){
        var lat = json.lat;
        var lon = json.long;
        reverseGeocode([lon,lat]);
        adjustMap([lon,lat]);
    });
}