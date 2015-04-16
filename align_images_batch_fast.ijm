//17.04.2015
// Macro to align images in a folder by drawing a line
// Author: Philipp Liehm, University of St Andrews
// Requirements:
// Two images which can be aligned easily (e.g. grid)
// folder with images which should be aligned


// open reference image
// draw line between two features which are far appart from each other
path_ref = File.openDialog("Choose the reference file");
	open(path_ref);
run("8-bit");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

img_reference = getTitle();
w1 = getWidth();
h1 = getHeight();

path_calib = File.openDialog("Choose an example file to calibrate");
	open(path_calib);
run("8-bit");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");

img_calib = getTitle();
w2 = getWidth();
h2 = getHeight();


do {selectImage(img_reference);
close("Overlay_after");
close("Overlay_before");
close(img_calib+" aligned to "+img_reference);
setTool("line");
waitForUser("Wait for User", "Draw a line in the reference image");

selectImage(img_reference);
	if (selectionType() !=5)
	exit("Sorry, you did not select a line, start again");
	getLine(x11,y11,x12,y12, lineWidth);
	if (x11==-1)
	exit("This macro requires a straight line selection");
	
	selectImage(img_calib);
	setTool("line");
	waitForUser("Wait for User", "Draw a line in the Icube calibration image");
	selectImage(img_calib);
	if (selectionType() !=5)
	exit("Sorry, you did not select a line, start again");
	getLine(x21,y21,x22,y22, lineWidth);
	if (x21==-1)
	exit("This macro requires a straight line selection");
	

//print(x11,y11,x12,y12);
//print(w1, h1);
// open on of the images to calibrate
// draw line between two features which are far appart from each other

//print(x21,y21,x22,y22);
//print(w2, h2);

dx1 = x12-x11;
dy1 = y12-y11;

dx2 = x22-x21;
dy2 = y22-y21;

alpha = atan(dy1/dx1);
beta = atan(dy2/dx2);
gamma_rad = beta-alpha;
gamma_deg = gamma_rad*180/PI;

//print("dx1: ", dx1);
//print("dx2: ", dx2);
//print("dy1: ", dy1);
//print("dy2: ", dy2);

//print("alpha: ",alpha);
//print("beta: ", beta);
//print("gamma_rad: ",gamma_rad);
//print("gamma_deg: ",gamma_deg);

// rotate calib image
selectImage(img_calib);
run("Duplicate...","title=Aligned" );
img_aligned = getTitle();
selectImage(img_aligned);
run("Rotate... ", "angle="+ -gamma_deg +" grid=1 interpolation=Bilinear");

// calculate position of points after roation
x31 = (x21 - w2/2)*cos(gamma_rad) - (h2/2-y21)*sin(gamma_rad) + w2/2;
x32 = (x22 - w2/2)*cos(gamma_rad) - (h2/2-y22)*sin(gamma_rad) + w2/2;

y31 = -((x21 - w2/2)*sin(gamma_rad) + (h2/2-y21)*cos(gamma_rad)) + h2/2;
y32 = -((x22 - w2/2)*sin(gamma_rad) + (h2/2-y22)*cos(gamma_rad)) + h2/2;

//print("new coordinates x31, x32, y31, y32:", x31,x32,y31,y32);

dx3 = abs(x31-x32);
dy3 = abs(y31-y32);

//print("new line dimensions are: ", dx3,dy3);
// calculate new dimensions
w3 = abs(w2*dx1/dx3);
h3 = abs(h2*dy1/dy3);

//print("new width and height are:", w3,h3);
run("Size...", "width="+w3+" height="+h3+" average interpolation=Bilinear");

// calculate translation

x_t = x11-abs(x31*dx1/dx3);
y_t = y11-abs(y31*dy1/dy3);

//print("translate with x_t and y_t:", x_t, y_t);

run("Translate...", "x="+x_t+" y="+y_t+" interpolation=None");

// make the new canvase size such that it fits the reference canvas
run("Canvas Size...", "width="+w1+" height="+h1+" position=Top-Left");

selectImage(img_calib);
run("Canvas Size...", "width="+w1+" height="+h1+" position=Center");
newImage("Overlay_before", "8-bit black", w1, h1, 1);
run("Add Image...", "image=["+img_calib+"] x=0 y=0 opacity=50 zero");
run("Add Image...", "image=["+img_reference+"] x=0 y=0 opacity=50 zero");
	
newImage("Overlay_after", "8-bit black", w1, h1, 1);
run("Add Image...", "image=["+img_aligned+"] x=0 y=0 opacity=50 zero");
run("Add Image...", "image=["+img_reference+"] x=0 y=0 opacity=50 zero");
} while(!(getBoolean("Are you happy with the alignment and want to proceed?")));

run("Close All");

path_calib=getDirectory("Choose the directiory with the images which should be aligned");
path_save=getDirectory("Choose a directory where the new images shall be stored");

Dialog.create("Title");
Dialog.addCheckbox("Do you want to convert the images to 8-bit?",true);
Dialog.show();

convert = Dialog.getCheckbox();

//print(convert);

setBatchMode(true);
list=getFileList(path_calib); 
list_length = list.length;
	for(i=0; i<list.length; i++) 
	{ 
	open(path_calib + list[i]);
	run("Rotate... ", "angle="+ -gamma_deg +" grid=1 interpolation=Bilinear");
	run("Translate...", "x="+x_t+" y="+y_t+" interpolation=None");
	run("Size...", "width="+w3+" height="+h3+" average interpolation=Bilinear");
	run("Canvas Size...", "width="+w1+" height="+h1+" position=Top-Left");
	if (convert==1)
	run("8-bit");
	saveAs("Tiff",path_save+list[i]);
	close();
	showProgress(i + 1, list_length);
	} 



