// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

 //Function to hide one element and show another.  Takes two element id's as params
function swap(id1, id2) {
  var elem1, elem2, vis1, vis2;
  if( document.getElementById ) { // this is the way the standards work
    elem1 = document.getElementById(id1);
    elem2 = document.getElementById(id2);
 
	  if(elem1.className == "hidden" && elem2.className == "shown") {
	    elem1.className = "shown";
	    elem2.className = "hidden";
	  } else {
	    elem1.className = "hidden";
	    elem2.className = "shown";
	  }
  } 
}


/*control showing or hiding the more info popup field on miscellaneous module*/

function show_more(){
  if(document.getElementById('more_info').style.display == 'none')
     {
       document.getElementById('more_info').style.display = 'block';
     }
  
}

function hide_more(){
  if(document.getElementById('more_info').style.display == 'block')
     {
       document.getElementById('more_info').style.display = 'none';
       document.getElementById('mod_more_info').value = "";
       tinyMCE.updateContent('mod_more_info');
     }

}



/*control the librarian module image options*/

function image_selection(v){
    if(v == 'Upload a new image from my computer')
    {
        
          document.getElementById('upload_image').style.display = 'block';
          document.getElementById('current_image').style.display = 'none';
        
     }
    else if (v == 'Remove my image')
    {
        
          document.getElementById('upload_image').style.display = 'none';
          document.getElementById('current_image').style.display = 'none';
        
    }
    else
    {
          document.getElementById('upload_image').style.display = 'none';
          document.getElementById('current_image').style.display = 'block';
    }
 
}

function checkEm() {
        var checkBoxes = document.getElementsByName('comment_ids[]');
        var checkMaster = $('checkMaster');
        var i = 0;

        if(checkMaster.hasClassName("unchecked")) {
          //We need to do the opposite...check all boxes
          for(i = 0; i < checkBoxes.length; i++) {
            checkBoxes[i].checked = true;
          }
          checkMaster.className = "checked";
        } else if(checkMaster.hasClassName("checked")) {
          //All boxes are checked, so let's uncheck em
          for(i = 0; i < checkBoxes.length; i++) {
            checkBoxes[i].checked = false;
          }
          checkMaster.className = "unchecked";
        }
      }

/***********************************************
* Fixed ToolTip script- � Dynamic Drive (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/
		
var tipwidth='250px' //default tooltip width
var tipbgcolor='#D1EEEE;'  //tooltip bgcolor
var disappeardelay=260  //tooltip disappear speed onMouseout (in miliseconds)
var vertical_offset="0px" //horizontal offset of tooltip from anchor link
var horizontal_offset="280px" //horizontal offset of tooltip from anchor link


/////No further editting needed

var ie4=document.all
var ns6=document.getElementById&&!document.all

if (ie4||ns6)
document.write('<div id="fixedtipdiv" style="visibility:hidden;width:'+tipwidth+';background-color:'+tipbgcolor+'" ></div>')

function getposOffset(what, offsettype){
var totaloffset=(offsettype=="left")? what.offsetLeft : what.offsetTop;
var parentEl=what.offsetParent;
while (parentEl!=null){
totaloffset=(offsettype=="left")? totaloffset+parentEl.offsetLeft : totaloffset+parentEl.offsetTop;
parentEl=parentEl.offsetParent;
}
return totaloffset;
}


function showhide(obj, e, visible, hidden, tipwidth){
if (ie4||ns6)
dropmenuobj.style.left=dropmenuobj.style.top=-500
if (tipwidth!=""){
dropmenuobj.widthobj=dropmenuobj.style
dropmenuobj.widthobj.width='226px'
}
if (e.type=="click" && obj.visibility==hidden || e.type=="mouseover")
obj.visibility=visible
else if (e.type=="click")
obj.visibility=hidden
}

function iecompattest(){
return (document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body
}

function clearbrowseredge(obj, whichedge){
var edgeoffset=(whichedge=="rightedge")? parseInt(horizontal_offset)*-1 : parseInt(vertical_offset)*-1
if (whichedge=="rightedge"){
var windowedge=ie4 && !window.opera? iecompattest().scrollLeft+iecompattest().clientWidth-15 : window.pageXOffset+window.innerWidth-15
dropmenuobj.contentmeasure=dropmenuobj.offsetWidth
if (windowedge-dropmenuobj.x < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure-obj.offsetWidth
}
else{
var windowedge=ie4 && !window.opera? iecompattest().scrollTop+iecompattest().clientHeight-15 : window.pageYOffset+window.innerHeight-18
dropmenuobj.contentmeasure=dropmenuobj.offsetHeight
if (windowedge-dropmenuobj.y < dropmenuobj.contentmeasure)
edgeoffset=dropmenuobj.contentmeasure+obj.offsetHeight
}
return edgeoffset
}


function fixedtooltip(menucontents, obj, e, tipwidth){
if (window.event) event.cancelBubble=true
else if (e.stopPropagation) e.stopPropagation()
clearhidetip()
dropmenuobj=document.getElementById? document.getElementById("fixedtipdiv") : fixedtipdiv
if (tipwidth!="")
 horizontal_offset= tipwidth+"px"   
else
  horizontal_offset="280px"
object = obj
oldClassName = object.className //remember the original className
object.className = object.className+" "+"selected"; //overwrite the className
dropmenuobj.innerHTML=menucontents

if (ie4||ns6){
showhide(dropmenuobj.style, e, "visible", "hidden", tipwidth)
dropmenuobj.x=getposOffset(obj, "left")
dropmenuobj.y=getposOffset(obj, "top")
dropmenuobj.style.left=dropmenuobj.x-clearbrowseredge(obj, "rightedge")+"px"
dropmenuobj.style.top=dropmenuobj.y-clearbrowseredge(obj, "bottomedge")+obj.offsetHeight+"px"
}
}

function hidetip(e){
if (typeof dropmenuobj!="undefined"){
if (ie4||ns6)
dropmenuobj.style.visibility="hidden"
}
}

function delayhidetip(){
if (ie4||ns6){
delayhide=setTimeout("hidetip()",disappeardelay)}
object.className = oldClassName; //set the object back to the original class name
}

function clearhidetip(){
if (typeof delayhide!="undefined")
clearTimeout(delayhide)
}

