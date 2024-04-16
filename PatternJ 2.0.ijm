////////////////////////////////////////////////////////////////////////
///////////    				PatternJ  2.0					   /////////
///////////		 				  2024						   /////////
///////////			 Melina Baheux Blin & Pierre Mangeol	   /////////
///////////				pierre.mangeol@univ-amu.fr			   /////////
////////////////////////////////////////////////////////////////////////


/////**************************************************************************/////

macro "Check your intensity profile(s) Action Tool - icon:PatternJ_check.png" {

	// Check if there is an image opened
	
	list = getList("image.titles");
		if (list.length == 0){
		  	Dialog.create("There is a problem...");
			Dialog.addMessage("No image can be found.\nOpen an image to analyze, draw a selection and try again.");
			Dialog.show;
			exit;}

//*** Displays the intensity profile(s) of the selection  ***//

	Profile_checker();
}

/////**************************************************************************/////


macro "Set parameters of your analysis Action Tool - icon:PatternJ_settings.png" {
	
//*** Checks if an image is opened (used to get the number of channels ***//

	list = getList("image.titles");
	if (list.length == 0){
	  	Dialog.create("There is a problem...");
		Dialog.addMessage("No image can be found.\nOpen an image to analyze and try again.");
		Dialog.show;}
		
//*** Checks if you are in the right folder and if images have been analysed ***//

	else{
	image_folder_name = getDirectory("Please select the folder containing your image(s)");
	Write_image_folder_name(image_folder_name); // creates or update the current folder name
	
	first_time = CheckForAnalysisFolder(image_folder_name); // returns 1 if the Analysis folder is missing
	
	//init - chooses the image to find how many channels need to be analyzed

	
	imagenumber = getTitle();
	
	if ((imagenumber.length) >= 15){
		if (substring(imagenumber, 0, 15)=="Profile checker"){
		// Check if profile window is the active window and select the corresponding image window
			imagenumber = substring(imagenumber, 17, lengthOf(imagenumber));}}
	selectWindow(imagenumber);
	
	//opens the settings window
	
	if(first_time == 1){AskForInfo(1, image_folder_name);}
	else{AskForInfo(2, image_folder_name);}}// "2" is to update values stored
}
	

/////**************************************************************************/////

macro "Visualize the extracted positions Action Tool - icon:PatternJ_extract.png" { 
	
//*** Extract positions from a selection ***//

	//*** Check if you are in the right folder and if images have been analysed ***//
	image_folder_name = Read_image_folder_name();// getDirectory("Please select the folder containing your image(s)");
	first_time = CheckForAnalysisFolder(image_folder_name); 
	
	//init - close potential profile window

	imagenumber = getTitle();
	
	if ((imagenumber.length) >= 15){
		if(substring(imagenumber, 0, 15)=="Profile checker"){
			
			selectWindow(imagenumber);
			close();// close Profile checker	
				
			imagenumber = substring(imagenumber, 17, lengthOf(imagenumber));}}
			
	if(isOpen("Profile checker: "+ imagenumber)){
	selectWindow("Profile checker: "+ imagenumber);
	close();}
	
	
	//*** Ask for information on the image sequence if first extraction for the entire folder ***//
	AskForInfo(first_time, image_folder_name);
		
	selectWindow(imagenumber);

	//*** Check if the opened window contains a selection *//

	if(is("line")==false){
		Dialog.create("There is a problem...");
		Dialog.addMessage("Sorry, I could not find a line selection.\nCan you try again with a line selection?");
		Dialog.show;
		exit;	
	}
	profile = getProfile();//initial check
	getPixelSize(unit, pixelWidth, pixelHeight);


	//*** Check if this is the first time that the image sequence is analyzed ***//
	//CheckimageStatus(image_folder_name);

	//*** Read the metadata file to know what to analyse ***//
	types = ReadInfo_type(image_folder_name); //array of char with type of channel
	nb_bands = ReadInfo_bands(image_folder_name); //array of int with number of channels
	channel_Z_or_M = ReadInfo_channel_ZM(image_folder_name); //array of char ("e" or "c") with info on data centered on Z-disk or M-line
	drawn_Z_or_M = ReadInfo_drawnZM(image_folder_name); //returns 0 if from (edge to edge)/(Z-disk to Z-disk), 1 if from (center to center)/(M-line-to-M-line)
	
	//*** Extract & save positions ***//
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(current_channel, slice, frame);
	
	for (i=1; i<channels + 1; i++){
		if (channels > 1) {
			Stack.setChannel(i);}
			
		profile = getProfile(); 
		avgSizeSarcomere = autoCorr(profile);//given in pixels
		posPattern = crossCorr(profile, avgSizeSarcomere, channel_Z_or_M[i-1], drawn_Z_or_M);
		
		Localization(image_folder_name, i, profile, types[i-1], nb_bands[i-1], avgSizeSarcomere, posPattern, channel_Z_or_M[i-1],1,0,0);
		// 1 and 0 at the end stands for saving temp files and timelapse ID
		}

	
	//*** Display positions in a graph ***//
	
	Profile_checker();
	Position_in_plot_adder(image_folder_name, imagenumber, types, pixelWidth,1);
	
	if (channels > 1) {
		Stack.setChannel(current_channel);}
	//*** Display positions on the image ***//
	//Display_positions(image_folder_name, types);
	}


/////**************************************************************************/////

macro "Extract & Save positions Action Tool - icon:PatternJ_extract_and_save.png" {
	
	////////////////////////////////////////
	// Extract positions from a selection //
	////////////////////////////////////////

	//*** Check if you are in the right folder and if images have been analysed ***//
	image_folder_name = Read_image_folder_name();//getDirectory("Please select the folder containing your image(s)");
	first_time = CheckForAnalysisFolder(image_folder_name); 

	//init - close potential profile window
	imagenumber = getTitle();
	
	if ((imagenumber.length) >= 15){
		if(substring(imagenumber, 0, 15)=="Profile checker"){
			imagenumber_actual_image = substring(imagenumber, 17, lengthOf(imagenumber));
			selectWindow(imagenumber);
			close();
			selectWindow(imagenumber_actual_image);
			imagenumber = imagenumber_actual_image;}}
			
	//*** Ask for information on the image sequence if first extraction for the entire folder ***//
	AskForInfo(first_time, image_folder_name);

	//*** Check if the opened window contains a selection *//

	if(is("line")==false){
		Dialog.create("There is a problem...");
		Dialog.addMessage("Sorry, I could not find a line selection.\nCan you try again with a line selection?");
		Dialog.show;
		exit;	
	}

	profile = getProfile();//initial check
	getPixelSize(unit, pixelWidth, pixelHeight);

	//*** Check if this is the first time that the image sequence is analyzed ***//
	CheckimageStatus(image_folder_name);

	//*** Read the metadata file to know what to analyse ***//
	types = ReadInfo_type(image_folder_name); //array of char with type of channel
	nb_bands = ReadInfo_bands(image_folder_name); //array of int with number of channels
	channel_Z_or_M = ReadInfo_channel_ZM(image_folder_name); //array of char ("Z" or "M") with info on data centered on Z-disk or M-line
	drawn_Z_or_M = ReadInfo_drawnZM(image_folder_name); //returns 0 if from (edge to edge)/(Z-disk to Z-disk), 1 if from (center to center)/(M-line-to-M-line)

	
	//*** Extract & save positions ***//
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(current_channel, slice, frame);			

	for (i=1; i<channels + 1; i++){
		if (channels > 1) {
			Stack.setChannel(i);}
		
		profile = getProfile(); 
		avgSizeSarcomere = autoCorr(profile);//given in pixels
		posPattern = crossCorr(profile, avgSizeSarcomere, channel_Z_or_M[i-1], drawn_Z_or_M);
		
		Localization(image_folder_name, i, profile, types[i-1], nb_bands[i-1], avgSizeSarcomere, posPattern, channel_Z_or_M[i-1],0,0,0);
		}

	
	//*** Save intensity in ROI ***//
	getSelectionCoordinates(xpoints, ypoints);
	getLine(x1, y1, x2, y2, lineWidth);
	selection_t = selectionType();
	SaveROI();
	makeSelection(selection_t, xpoints, ypoints);
	setLineWidth(lineWidth);

	//*** Display positions in a graph ***//
	
	Profile_checker();
	if (channels > 1) {
		Stack.setChannel(current_channel);}
		
	Position_in_plot_adder(image_folder_name,imagenumber,types, pixelWidth,0);
	
	if (channels > 1) {
		Stack.setChannel(current_channel);}
	//*** Display positions ***//
	//Display_positions(image_folder_name, types);
	}

/////**************************************************************************/////

macro "Analysis Action Tool - icon:PatternJ_analysis.png" {
	////////////////////////////////////////
	// Estimates sarcomere lengths, bands,
	// and domain positions based on several 
	// image sequences and region of interest
	////////////////////////////////////////
	
	// Checks if the Analysis folder was created

		image_folder_name = Read_image_folder_name();//getDirectory("Please select the folder containing your image(s)");
		if (CheckForAnalysisFolder(image_folder_name)==1) {
				Dialog.create("There is a problem...");
				Dialog.addMessage("No analysis can be found");
				Dialog.show;
			}
	
		else {		
		//*** Check names of images analyzed ***//
		imagenames = CheckimageNames(image_folder_name);
	
		//*** Read the metadata file to know what to analyse ***//
		types = ReadInfo_type(image_folder_name); //array of char with type of channel
		nb_bands = ReadInfo_bands(image_folder_name); //array of int with number of bands in channels
		if (types.length > 1) {
			ref_channel = AskForAnalysis(types, nb_bands);}
		else {
			ref_channel = 1;
		}

			
		sarcomere_for_concatenated_data = Save_sarcomere_length_data(image_folder_name, imagenames, ref_channel, types, nb_bands);
		Concatenated_data(image_folder_name, imagenames, types, nb_bands, sarcomere_for_concatenated_data);
		
		Display_average_pattern(image_folder_name, ref_channel, imagenames, types);
		}
	}

/////**************************************************************************/////

var mCmds = newMenu("Information and Help Menu Tool",newArray("Basic tutorial","Open the video tutorial in YouTube", "Version Information"));

macro "Information and Help Menu Tool - icon:PatternJ_help_video_tutorial.png"
{
	cmd = getArgument();
	if (cmd!="-" && cmd == "Basic tutorial") 
		{Dialog.createNonBlocking("Basic tutorial");
			
			Dialog.addMessage("Basic walkthrough", 14, "#0000ff");
			
			Dialog.addMessage("Step 1", 12, "#007777");
								
			Dialog.addMessage("Make a line selection on your image (it can be a curve).\n"+
								"Pick the largest linewidth possible to improve the reliability of results.");
			
			Dialog.addMessage("Step 2", 12, "#007777");
								
			Dialog.addMessage("Press the \"Check\" button to visualize your profile.\n");
			
			Dialog.addMessage("Step 3", 12, "#007777");
								
			Dialog.addMessage("Press the \"Set param\" button to specifiy the type of feature to extract.\n");
			
			Dialog.addMessage("Step 4", 12, "#007777");
								
			Dialog.addMessage("Press \"Extract\" to check how well the features are extracted.\n");
			
			Dialog.addMessage("Step 5", 12, "#007777");
								
			Dialog.addMessage("If you are happy the the results of the previous step,\n"+
								"press \"Extract & Save\" to save the results.\n "+
								"\nYou can repeat steps 1, 4 and 5 to as many selections as you want.");
								
			Dialog.addMessage("Step 6", 12, "#007777");
								
			Dialog.addMessage("Ready to get your data analyzed?\n"+
								"press the \"Analysis\" button.");
								
			Dialog.addMessage("#Tip 1: to go faster hit the \"Enter\" key when prompted for where is your image.\n \n"+
								"#Tip 2: Are you on a Mac? You may want to follow our instructions on the video tutorial\n"+
								"or on our website to be sure you get instruction when prompted to open a folder.");
			
			Dialog.addMessage("Still unsure about how to use PatternJ?\n"+
								"Click the \"Help\" button below to visit our website.", 14, "#0000ff");
			
			Dialog.addMessage("You will find a user manual and a video tutorial.\n"+
			" \nYou can also watch our video tutorial directly\nby clicking on the \"Tutorial\" button\n", 12, "#0000aa");
			
			Dialog.addHelp("https://sites.google.com/view/patternj");
			Dialog.show;}

	if (cmd!="-" && cmd == "Open the video tutorial in YouTube") 
		{exec("open", "https://www.youtube.com/watch?v=0p5_Crc4aPw");
		}
		
	if (cmd!="-" && cmd == "Version Information") 
		{Dialog.create("Information and Help");
			Dialog.addMessage("You are using PatternJ version 2.0");
			Dialog.show;
		}
}


/////**************************************************************************/////

var mCmds = newMenu("Options Menu Tool",newArray("Smooth your image with Gaussian blur (value between 0.5 and 2 is best)","EM preparation (background removal and LUT inversion)"));

macro "Options Menu Tool - icon:PatternJ_options.png"
{
	cmd = getArgument();
	if (cmd!="-" && cmd == "Smooth your image with Gaussian blur (value between 0.5 and 2 is best)") 
		{//*** Blurs the image. Useful for large features with noise  ***//

		run("Gaussian Blur...");}

	else if (cmd!="-" && cmd == "EM preparation (background removal and LUT inversion)") 
		{
		run("Subtract Background...", "rolling=50 light disable");
		run("Invert");}
		}
}


/////**************************************************************************/////

var mCmds = newMenu("ROI Menu Tool",newArray("Only open selections made with PatternJ (no direct analysis)","Select ROIs and automatically extract"));

macro "ROI Menu Tool - C000 T0c12R T8c12O Thc12I" {
	
	cmd = getArgument();
	if (cmd!="-" && cmd == "Only open selections made with PatternJ (no direct analysis)") {
		image_folder_name = getDirectory("Please select the folder containing your image(s)");
	
	roi_file_path = image_folder_name + File.separator + "Analyses" + File.separator + "ROIset.zip";
		if(File.exists(roi_file_path)){
			roiManager("open", roi_file_path);}
		else{
			Dialog.create("There is a problem...");
			Dialog.addMessage("I cannot find previous selections (ROIs) saved for this image.\nStart extracting positions, selections will be saved automatically");
			Dialog.show;
			}	
	}
	
	else if (cmd!="-" && cmd == "Select ROIs and automatically extract")
		{//// make the user choose between new timelapse and previous timelapse (open previous selections from user)
	
	//*** Checks if an image is opened (used to get the number of channels ***//
	
		list = getList("image.titles");
		if (list.length == 0){
		  	Dialog.create("There is a problem...");
			Dialog.addMessage("No image can be found.\nOpen an image to analyze and try again.");
			Dialog.show;
			exit;}
			
	// Make sure an image sequence is picked
		
		imagenumber = getTitle();
		
		if ((imagenumber.length) >= 15){
			if (substring(imagenumber, 0, 15)=="Profile checker" || substring(imagenumber, 0, 15)=="Pattern size vs"){
			// Check if profile window is the active window and select the corresponding image window
			Dialog.create("There is a problem...");
			Dialog.addMessage("It looks like the current active window is a graph.\n \nCan you select an image sequence?");
			Dialog.show;
			exit;}}
	
	// Make sure the parameters are well set
			
		//*** Checks if you are in the right folder and if images have been analysed ***//

		image_folder_name = getDirectory("Please select the folder containing your image(s)");
		Write_image_folder_name(image_folder_name); // creates or update the current folder name
		
		first_time = CheckForAnalysisFolder(image_folder_name); // returns 1 if the Analysis folder is missing
		
		//init - chooses the image to find how many channels need to be analyzed

		
		//opens the settings window
		
		if(first_time == 1){AskForInfo(1, image_folder_name); }
		//else{AskForInfo(2, image_folder_name);}// "2" is to update values stored
		
		//*** Ask for information on the image sequence if first extraction for the entire folder ***//
		
		ROI_ID = Introduction_ROIs();
		
		
		Extract_and_save_ROIs(image_folder_name, imagenumber, ROI_ID); // Extract, save results and display a stacked plot with all localizations
		setBatchMode("exit and display");
	}
		
		
	}
	
	
//macro "Open previous selections Action Tool - C000 T0c12R T8c12O Thc12I" {
//	
//	image_folder_name = getDirectory("Please select the folder containing your image(s)");
//	
//	roi_file_path = image_folder_name + File.separator + "Analyses" + File.separator + "ROIset.zip";
//		if(File.exists(roi_file_path)){
//			roiManager("open", roi_file_path);}
//		else{
//			Dialog.create("There is a problem...");
//			Dialog.addMessage("I cannot find previous selections (ROIs) saved for this image.\nStart extracting positions, selections will be saved automatically");
//			Dialog.show;
//			}
//}

/////**************************************************************************/////

macro "Timelapse Action Tool - icon:PatternJ_timelapse.png" {//// make the user choose between new timelapse and previous timelapse (open previous selections from user)
	
	//*** Checks if an image is opened (used to get the number of channels ***//
	
		list = getList("image.titles");
		if (list.length == 0){
		  	Dialog.create("There is a problem...");
			Dialog.addMessage("No image can be found.\nOpen an image to analyze and try again.");
			Dialog.show;
			exit;}
			
	// Make sure an image sequence is picked
		
		imagenumber = getTitle();
		
		if ((imagenumber.length) >= 15){
			if (substring(imagenumber, 0, 15)=="Profile checker" || substring(imagenumber, 0, 15)=="Pattern size vs"){
			// Check if profile window is the active window and select the corresponding image window
			Dialog.create("There is a problem...");
			Dialog.addMessage("It looks like the current active window is a graph.\n \nCan you select an image sequence?");
			Dialog.show;
			exit;}}
	
	// Make sure the parameters are well set
			
		//*** Checks if you are in the right folder and if images have been analysed ***//
		//directoryPath = Read_image_folder_name();
		//File.setDefaultDir(directoryPath);
		image_folder_name = getDirectory("Please select the folder containing your image(s)");
		Write_image_folder_name(image_folder_name); // creates or update the current folder name
		
		first_time = CheckForAnalysisFolder(image_folder_name); // returns 1 if the Analysis folder is missing
		
		//init - chooses the image to find how many channels need to be analyzed

		
		//opens the settings window
		
		if(first_time == 1){AskForInfo(1, image_folder_name); }
		else{AskForInfo(2, image_folder_name);}// "2" is to update values stored
		
		//*** Ask for information on the image sequence if first extraction for the entire folder ***//
		
		frame_or_slice_chosen_channel = Introduction_timelapse(); // message how to draw selections, returns whether drawn along time or space
		frame_or_slice_chosen_channel = split(frame_or_slice_chosen_channel, "_");
		frame_or_slice = frame_or_slice_chosen_channel[0];
		chosen_channel = parseFloat(frame_or_slice_chosen_channel[1]);
	
		timelapseID = Save_selection_ROI_for_timelapse(); // Save the few selections made by the user and returns the suffix of the ROIset file
		setBatchMode("hide");
		frame_or_slice_analyzed_min_frame = ROI_morpher(frame_or_slice, timelapseID); // Morph the selections on frames not drawn by the user to obtain selections for all frames
		
		frame_or_slice_analyzed_min_frame = split(frame_or_slice_analyzed_min_frame, "_");
		frame_or_slice_analyzed = frame_or_slice_analyzed_min_frame[0];
		min_frame = parseFloat(frame_or_slice_analyzed_min_frame[1]);
		
		Extract_and_save_timelapse(image_folder_name, imagenumber, timelapseID); // Extract, save results and display a stacked plot with all localizations
		setBatchMode("exit and display");
		// Analyse, gather all data in one file, display position vs time in one graph,
		// distribution of pattern length over time
		
		AnalysisForTimelapse(image_folder_name, imagenumber, timelapseID, chosen_channel, frame_or_slice_analyzed, min_frame);
		
		//selectWindow(imagenumber);
	}
	


/////**************************************************************************/////

//macro "Extract based on ROIs Action Tool - C000 T0c12R T8c12O Thc12I Tjc12s" {//// make the user choose between new timelapse and previous timelapse (open previous selections from user)
//	
//	//*** Checks if an image is opened (used to get the number of channels ***//
//	
//		list = getList("image.titles");
//		if (list.length == 0){
//		  	Dialog.create("There is a problem...");
//			Dialog.addMessage("No image can be found.\nOpen an image to analyze and try again.");
//			Dialog.show;
//			exit;}
//			
//	// Make sure an image sequence is picked
//		
//		imagenumber = getTitle();
//		
//		if ((imagenumber.length) >= 15){
//			if (substring(imagenumber, 0, 15)=="Profile checker" || substring(imagenumber, 0, 15)=="Pattern size vs"){
//			// Check if profile window is the active window and select the corresponding image window
//			Dialog.create("There is a problem...");
//			Dialog.addMessage("It looks like the current active window is a graph.\n \nCan you select an image sequence?");
//			Dialog.show;
//			exit;}}
//	
//	// Make sure the parameters are well set
//			
//		//*** Checks if you are in the right folder and if images have been analysed ***//
//
//		image_folder_name = getDirectory("Please select the folder containing your image(s)");
//		Write_image_folder_name(image_folder_name); // creates or update the current folder name
//		
//		first_time = CheckForAnalysisFolder(image_folder_name); // returns 1 if the Analysis folder is missing
//		
//		//init - chooses the image to find how many channels need to be analyzed
//
//		
//		//opens the settings window
//		
//		if(first_time == 1){AskForInfo(1, image_folder_name); }
//		//else{AskForInfo(2, image_folder_name);}// "2" is to update values stored
//		
//		//*** Ask for information on the image sequence if first extraction for the entire folder ***//
//		
//		ROI_ID = Introduction_ROIs();
//		
//		
//		Extract_and_save_ROIs(image_folder_name, imagenumber, ROI_ID); // Extract, save results and display a stacked plot with all localizations
//		setBatchMode("exit and display");
//	}











	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////// Functions ////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////

function Profile_checker() {

    /// start by checking if the window on top is an image or a plot of profile.
    /// If profile closes it, otherwise continue
    
	    imagenumber = getTitle();
	    
	    if ((imagenumber.length) >= 15){
	        if(substring(imagenumber, 0, 15)=="Profile checker"){
	        imagenumber_actual_image = substring(imagenumber, 17, lengthOf(imagenumber));
	        selectWindow(imagenumber);
	        close();
	        imagenumber = imagenumber_actual_image;
	        }}
	    
	    if(isOpen("Profile checker: "+ imagenumber)){
	        selectWindow("Profile checker: "+ imagenumber);
	        close();}

    // Extracts profiles
    
	    selectWindow(imagenumber);    
		
		if(is("line")==false){
			Dialog.create("There is a problem...");
			Dialog.addMessage("Sorry, I could not find a line selection.\nCan you try again with a line selection?");
			Dialog.show;
			exit;	
			}
		
	    profile = getProfile();//check if a selection is there
	
		xValues = Array.getSequence(profile.length); // sets the values in pixels for x axis
	    Stack.getDimensions(width, height, channels, slices, frames);
	    Stack.getPosition(current_channel, slice, frame);// used to come back to inital channel at the end of macro

		    // saves all profiles in one array
		    all_profiles = newArray();
		    for (i=1; i<channels + 1; i++){
		        if(channels >1){
		        	Stack.setChannel(i);}
		        profile = getProfile();
		        all_profiles = Array.concat(all_profiles,profile);}


	// sets graph colors 
	    Plotcolors = newArray(channels);
	
	    if (channels > 1) {
	        for(c=1; c<channels+1; c++){
	            
	            Stack.setChannel(c);
	        
	            getLut(reds, greens, blues);
	            
	            R = toHex(reds[reds.length-1]);
	            G = toHex(greens[greens.length-1]);
	            B = toHex(blues[blues.length-1]);
	
	        	// makes sure there is no white graph, and gives darker colors for most used colors
	            if(R=="ff" && G=="ff" && B == "ff"){R="00"; G="00"; B="00";}
	            if(R=="0" && G=="ff" && B == "0"){R="00"; G="aa"; B="00";}
	            if(R=="ff" && G=="0" && B == "0"){R="dd"; G="00"; B="00";}
	            if(R=="0" && G=="0" && B == "ff"){R="00"; G="00"; B="cc";}
	            if(R=="ff" && G=="0" && B == "ff"){R="dd"; G="00"; B="cc";}
	            if(R=="0"){R="00";}
	            if(G=="0"){G="00";}
	            if(B=="0"){B="00";}
	        
	            Plotcolors[c-1] = "#" + R + G + B;
	            }}
	     else {
	     		Plotcolors[0] = "#000000";}
        
	// creates the graph with profiles            
        Plot.create("Profile checker: "+imagenumber, "Pixel position", "Normalized intensity");

                if(channels >1){
                    Stack.setChannel(current_channel);
                    Plot.setColor("black");
                    Plot.addText("channels", 0, 0);}
                    
                for (i=0; i<channels; i++){
                    subprofile = Array.slice(all_profiles,profile.length*i,profile.length*(i+1));
                    Array.getStatistics(subprofile, min, max, mean, stdDev);
                    for (k = 0; k < subprofile.length; k++) {
                        subprofile[k] = (subprofile[k]-min)/(max-min)+channels-1-i;
                        }
                    Plot.setColor(Plotcolors[i]);
                    Plot.add( "line", xValues, subprofile); // display plot
                    display_channel = toString(i+1);
                    if(channels >1){Plot.addText(display_channel, 0.15 + i/25, 0);//add the number of channel with its color on top of the graph
                    }}
                    
        Plot.setLimits(0, profile.length, -0.1, channels+0.1);                               
}


/////**************************************************************************/////

function CheckForAnalysisFolder(image_folder_name){
	//Asks the user if the system is in the right folder and checks whether the data has ever been analyzed.
	//If the data was analyzed, a folder "Analyses" would be present.
	// returns 1 if folder "Analyses" exists, 0 otherwise

		//Check if the metadata has ever been created - ie if an analysis has ever been carried out
	if (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt")!=1) {
	output = 1;
	}
	else {output = 0;}

	return output;
}

/////**************************************************************************/////

function AskForInfo(first_time, image_folder_name) {
	//If this is the first time the user analyse data, creates a metadata file with the necessary info for the analysis
	
	getPixelSize(unit, pixelWidth, pixelHeight);
	if ((first_time==1) | (first_time==2)){
		if (first_time==1){
			//*** Open Dialog to get informations from the user, because no metadata was found ***//
		
			/// Save metadata file with
			///		- first line nb of channels
			///		- 3*n line type of channel n (n= 1,2,3...)
			///		- 3*n+1 number of bands of channel n
			///		- 3*n+2 bands in proximity of m-line of z-disk
			
			Stack.getDimensions(width, height, channels, slices, frames);
			
		
			Dialog.createNonBlocking("Provide some information");
			Dialog.addMessage("Please provide some information \non your data and wanted analysis", 15, "#0000ff");
			
			
			if (channels == 1) {
				Dialog.addChoice("Data type/analysis:",
								 newArray("individual band(s)", "very close individual band(s)", "block(s)", "block with middle band (sarcomeric actin)", "single pattern", "other?"));
				
				Dialog.addNumber("Number of bands or blocks (if it applies):", 1);
								}
			
			else {
				for (i = 1; i < channels+1; i++) {
					
					Dialog.addChoice("Channel "+ i + " data type/analysis:",
									 newArray("individual band(s)", "very close individual band(s)", "block(s)", "block with middle band (sarcomeric actin)", "single pattern", "other?"));
					Dialog.addNumber("Number of bands or blocks (if it applies):", 1);
					//Dialog.addNumber("Threshold (applies on actin only):", 0.5);
					Dialog.addChoice("Channel "+ i + " centered on:", newArray("edge (Z-disc)", "center (M-line)"));
					Dialog.addMessage(" ");
						}}
					Dialog.addMessage("My selections are drawn center-to-center or edge-to-edge (M-line-to-M-line or Z-disc-to-Zdisc):");
					Dialog.addChoice("", newArray("center-to-center (M-line-to-M-line)", "edge-to-edge (Z-disc-to-Zdisc)"));
					
					//Dialog.addMessage("NB: if your data is of block or other type \nplease contact Pierre to find a solution.");
						
					Dialog.show;}

		else{//Metadata was found: user can update his/her choice
			 //Read previous settings stored for this dataset to ease the choice
			
			type_analysis = newArray("individual band(s)", "very close individual band(s)", "block(s)", "block with middle band (sarcomeric actin)", "single pattern", "other?");
			types = ReadInfo_type(image_folder_name); // returns "i" for band, "v" for very close bands, "b" for block, "q" for sarcomeric actin, "s" for single pattern, "o" for other
			types_index= newArray(types.length);
			mystring = "ivbqso";
			for (i = 0; i < types.length; i++) {
				types_index[i] = mystring.indexOf(types[i]);}
	
			bands = ReadInfo_bands(image_folder_name);
	
			Z_or_M_centered = newArray("edge (Z-disc)", "center (M-line)");
			ZM = ReadInfo_channel_ZM(image_folder_name);
			ZM_index= newArray(ZM.length);
			mystring = "ec";
			for (i = 0; i < ZM.length; i++) {
				ZM_index[i] = mystring.indexOf(ZM[i]);}
	
			Stack.getDimensions(width, height, channels, slices, frames);
	
			Dialog.createNonBlocking("Provide some information");
			Dialog.addMessage("Please provide some information \non your data and wanted analysis", 15, "#0000ff");			
			
			if (channels == 1) {
				Dialog.addChoice("Data type/analysis:", type_analysis, type_analysis[types_index[0]] );
				
				Dialog.addNumber("Number of bands or blocks (if it applies):", bands[0]);}
			
			else {
				for (i = 1; i < channels+1; i++) {
			
				Dialog.addChoice("Channel "+ i + " data type/analysis:", type_analysis, type_analysis[types_index[i-1]]);
				Dialog.addNumber("Number of bands or blocks (if it applies):", bands[i-1]);
				//Dialog.addNumber("Threshold (applies on actin only):", 0.5);
				Dialog.addChoice("Channel "+ i + " centered on:", Z_or_M_centered, Z_or_M_centered[ZM_index[i-1]]);
				Dialog.addMessage(" ");
					}}
					
			Dialog.addMessage("My selections are drawn center-to-center or edge-to-edge (M-line-to-M-line or Z-disc-to-Zdisc):");
			Dialog.addChoice("", newArray("center-to-center (M-line-to-M-line)", "edge-to-edge (Z-disc-to-Zdisc)"));
				
			Dialog.show;}

		//*** If the user does not press cancel, creates the folder and necessary files ***//
		
		
		//********** Writes in metadata file *************//
		
	
		//Create the Analysis and internal folders if they do not exist
		if (File.exists(image_folder_name + File.separator + "Analyses")!=1) {
			File.makeDirectory(image_folder_name + File.separator + "Analyses");}
			
		if (File.exists(image_folder_name + File.separator + "Analyses" +  File.separator + "internal")!=1) {
			File.makeDirectory(image_folder_name + File.separator + "Analyses" +  File.separator + "internal");}
	
		//Create file with metadata
		File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt")
		f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt");
		
		print(f, "channels="+ channels);//write in first line of metadata number of channels
		
		error_band_number = 0;
		
		if (channels == 1) {
			type = Dialog.getChoice();
		  	if (type == "block with middle band (sarcomeric actin)") {
				type = "q sarcomeric actin";}
			
		  	bandnumber = Dialog.getNumber();
		  	
		  	// Check that the number of band or block is higher than 0  
		  	if (type.indexOf("band")>0 || type.indexOf("block")>0){
		  		if(bandnumber<1){
		  			error_band_number = 1;
		  			bandnumber = 1;
		  		}}

		  	print(f, "type="+ type);
		  	if (type.indexOf("band")==-1 && type.indexOf("block")==-1){print(f, "bandnumber=0");}
		  	else{print(f, "bandnumber="+ bandnumber);}
		}
	
		else {
	
			for (i = 1; i < channels+1; i++) {
				type = Dialog.getChoice();
				if (type == "block with middle band (sarcomeric actin)") {
					type = "q sarcomeric actin";}
					
				bandnumber = Dialog.getNumber();
				
				// Check that the number of band or block is higher than 0  
		  		if (type.indexOf("band")>0 || type.indexOf("block")>0){
			  		if(bandnumber<1){
			  			error_band_number = 1;
			  			bandnumber = 1;
			  		}}
				
				
				  	//threshold = Dialog.getNumber();
				Z_or_M = Dialog.getChoice();
				print(f, "type="+ type);
				if (type.indexOf("band")==-1 && type.indexOf("block")==-1){print(f, "bandnumber=0");}
				else{print(f, "bandnumber="+ bandnumber);}
					print(f, "centered on "+ Z_or_M);}
			}
			  
		ZtoZ_or_MtoM_drawn = Dialog.getChoice();
		print(f, "Drawn "+ ZtoZ_or_MtoM_drawn);
		print(f, "Pixel size = "+ pixelWidth);
	
	
		File.close(f);
		if(error_band_number == 1){
		Dialog.create("There is a problem...");
		Dialog.addMessage("You selected band(s) or block(s), but \"0\" is indicated as their number per repeat.\n" +
		"Can you try again to make it fit the number of band or block, or select another option?");
		Dialog.show;
		exit;	}
		}
	else{}
	
	}

/////**************************************************************************/////

function ReadInfo_type(image_folder_name){
//Read channel type(s) in metadata file

	//Open the metadata file
	metadatafile = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt");

	//Rows into an array of strings
	rows=split(metadatafile, "\n"); 
	first_row = split(rows[0], "=");
	channels = parseInt(first_row[1]);
	channel_type = newArray(channels);

	// returns "i" for band, "a" for actin, "b" for block, "o" for other, "q" for quantile algorithm for actin, "v" for very close bands, "s" for single pattern, "o" for others
	for (i = 0; i < channels; i++) {
		channel_type[i] = rows[3*i+1].charAt(rows[3*i+1].indexOf("=")+1); 
		}
	
	return channel_type;
	}

/////**************************************************************************/////

function ReadInfo_channel_ZM(image_folder_name){
//Read channel Z or M line centered in metadata file
// returns "Z" for Z-disk centered signal or "M" for M-line centered signal

	//Open the metadata file
	metadatafile = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt");

	//Rows into an array of strings
	rows=split(metadatafile, "\n"); 
	first_row = split(rows[0], "=");
	channels = parseInt(first_row[1]);
	channel_type = newArray(channels);
	channel_Z_or_M = newArray(channels);
	
	for (i = 0; i < channels; i++) {
		channel_Z_or_M[i] = substring(rows[3*(i+1)],12,13);// returns "e" of edge for Z-disk centered signal or "c" of center for M-line centered signal
		}
	
	return channel_Z_or_M;
	}
	
/////**************************************************************************/////

function ReadInfo_bands(image_folder_name){
//Reads number of band(s) in metadata file and returns it

	//Open the metadata file
	metadatafile = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt");

	//Read file and find the info about bands in each channel
	rows=split(metadatafile, "\n"); 
	first_row = split(rows[0], "=");
	channels = parseInt(first_row[1]);

	nb_band = newArray(channels);
	
	for (i = 0; i < channels; i++) {
		nb_band[i] = parseInt(rows[3*i+2].substring(rows[3*i+2].indexOf("=")+1));
	}
	return nb_band;
	}
	
/////**************************************************************************/////

function ReadInfo_drawnZM(image_folder_name){
//Reads number of band(s) in metadata file and returns it

	//Open the metadata file
	metadatafile = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt");

	//Read file and find the info about bands in each channel
	rows=split(metadatafile, "\n"); 
	first_row = split(rows[0], "=");
	channels = parseInt(first_row[1]);
	
	ZM = substring(rows[1+channels*3], 6, 7);
	if(ZM == "e"){zero_or_one = 0;}
	else{zero_or_one = 1;}
	
	return zero_or_one;//returns 0 if from (edge to edge)/(Z-disk to Z-disk), 1 if from (center to center)/(M-line-to-M-line)
	}

/////**************************************************************************/////

function Write_image_folder_name(image_folder_name){
	// Saves the name of the current image folder in the macro toolset folder to avoid the user indicating the folder name each time
	
	macro_folder = getDir("macros");

	if (File.exists(macro_folder + File.separator + "toolsets" + File.separator + "PatternJ_internal_files")!=1) {
		File.makeDirectory(macro_folder + File.separator + "toolsets" + File.separator + "PatternJ_internal_files");}
	
	file_with_current_folder_path = macro_folder + File.separator + "toolsets" + File.separator + "PatternJ_internal_files"+
									File.separator + "current_folder.txt";

	File.saveString("", file_with_current_folder_path)
		f = File.open(file_with_current_folder_path);
		
		print(f, image_folder_name);//write in first line of metadata number of channels

		File.close(f);}

/////**************************************************************************/////

function Read_image_folder_name(){
	// Saves the name of the current image folder in the macro toolset folder to avoid the user indicating the folder name each time
	// If no analysis function was used for more than 2 hours, the algorithm asks to confirm the image folder 
	
	macro_folder = getDir("macros");
	file_with_current_folder_path = macro_folder + File.separator + "toolsets" + File.separator + "PatternJ_internal_files"+
									File.separator + "current_folder.txt";
									
	if (File.exists(macro_folder + File.separator + "toolsets" + File.separator + "PatternJ_internal_files")!=1) {
		image_folder_name = getDirectory("Please select the folder containing your image(s)");
		Write_image_folder_name(image_folder_name);
	}
	
	else{
		//if it exists, make sure it was not saved too long ago, which likely means the user will not use the right folder
		current_folder_time_last_modified = File.dateLastModified(file_with_current_folder_path);

		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		
		last_mod_year = parseFloat(substring(current_folder_time_last_modified, 24));
		last_mod_month = substring(current_folder_time_last_modified, 4, 7);
		last_mod_day = parseFloat(substring(current_folder_time_last_modified, 8, 10));
		MonthNames_str = "JanFebMarAprMayJunJulAugSepOctNovDec";
		month3fold = indexOf(MonthNames_str, last_mod_month);
		last_mod_month_number = month3fold/3; // Jan is 0
		
		last_mod_hour = parseFloat(substring(current_folder_time_last_modified, 11, 13));
		last_mod_min = parseFloat(substring(current_folder_time_last_modified, 14, 16));
		
		time_diff_min = (year-last_mod_year)*365*24*60 + (month-last_mod_month_number)*31*24*60 +
						(dayOfMonth-last_mod_day)*24*60 + (hour - last_mod_hour)*60 + minute-last_mod_min;
		
		if (time_diff_min > 120) {
			image_folder_name = getDirectory("Please select the folder containing your image(s)");
			Write_image_folder_name(image_folder_name);}
		
		else{
			image_folder_name_file = File.openAsString(file_with_current_folder_path);
			rows=split(image_folder_name_file, "\n");
			image_folder_name = rows[0];
			Write_image_folder_name(image_folder_name);}
		}
		
	return image_folder_name;
}

/////**************************************************************************/////
/////**************************************************************************/////
/////***************             Analysis functions            ****************/////
/////**************************************************************************/////
/////**************************************************************************/////


function autoCorr(profile) { 
//Returns a rough estimate of the sarcomere size through autocorrelation 

	Array.getStatistics(profile, min, max, mean, stdDev);
	centered_Profile = Array.copy(profile);
	for (l=0; l<lengthOf(profile); l++) {centered_Profile[l] = centered_Profile[l] - mean;} // substract the mean value of the profile to itself
	zeroArray = newArray(lengthOf(centered_Profile));
	centered_Profile = Array.concat(centered_Profile, zeroArray);
	
	autoCorrelation = newArray(lengthOf(centered_Profile)); // declare autocorrelation array
	profile_padded = Array.copy(centered_Profile);

	for (l=0; l<lengthOf(centered_Profile)/2; l++) {
		sum = 0;
		for (k=0; k<lengthOf(centered_Profile); k++) {
			sum = sum + profile_padded[k]*centered_Profile[k];
			}
		autoCorrelation[l] = sum;
		Array.rotate(centered_Profile, 1);} // Rotates the array elements by "d" (here 1) steps (positive "d" = rotate right).

	AC_length = autoCorrelation.length; 
	X_axis = Array.getSequence(AC_length); // Returns an array containing the numeric sequence 0,1,2...n-1. 
	
	max = Array.findMaxima(autoCorrelation,1);
	// Returns an array holding the peak positions (sorted with descending strength). "Tolerance" is the minimum amplitude difference needed to separate two peaks. 
	if(max.length > 3){
	max = Array.slice(max, 0, 4);
	max = Array.sort(max);} 
	// sorting the array of positions makes sure that the 2nd peak in the autocorrelation is the one that will be picked and not the 3rd, 4th...
	// one, which can sometimes be higher than the 2nd one.

	else if(max.length > 2){
	max = Array.slice(max, 0, 3);
	max = Array.sort(max);}

	
	// Fit the first maximum of the autocorrelation function to get subpixel resolution on the sarcomere length
	start = maxOf(0,max[1] - 5); // max[1] Select the second pic of the array
	end = minOf(max[1] + 5, AC_length);
	
	small_AC = Array.slice(autoCorrelation,start,end); // Extracts a part of an array and returns it. 
	small_x = Array.slice(X_axis,start,end); // Extracts a part of an array and returns it. 
	Fit.doFit("Gaussian", small_x, small_AC); // Fits the specified equation to the points defined by xpoints, ypoints. 

	avgSizeSarcomere = (Fit.p(2)); // Returns the position of the center of the first peak in the autocorrelation function.

	
	return avgSizeSarcomere; // Returns the average sarcomere size in pixels. 
}


/////**************************************************************************/////

function crossCorr(profile, avgSizeSarcomere, channel_ZM, drawn_Z_or_M) {
//Returns a rough estimate of the pattern positions through cross-correlation 
	
//Define a pattern based on max value
	maximum = Array.findMaxima(profile, 10);

	avg = avgSizeSarcomere; //pattern size in pixel
	
	ult = profile.length-1; // maximum profile index

	k=0; //use as logic to check if pattern was found
   //Define the pattern based on the maximum peak in the profile and the sarcomere size. If located too much on an edge, check the next max peak
	for(i=0; i<maximum.length; i++){ 
		start_avg = maximum[i] - (avg/2); // max[i] Select the ith peak in the profile
		end_avg = maximum[i] + (avg/2);
		if(start_avg > 0 && end_avg < ult){ 
			pattern = Array.slice(profile, start_avg, end_avg);// extract pattern
			k=1;
			break; // exit as a pattern is found
		}
	}
	if (k==0) {
		Dialog.create("There is a problem...");
		Dialog.addMessage("Your selection might be too small \nPlease try a new selection");
		Dialog.show;
		exit;	}
	

	Array.getStatistics(profile, min, max, mean, stdDev); // Returns the min, max, mean, and stdDev of profile

	//Prepare the profile to achieve the cross-correlation
	//pads mean value of pattern with pattern size at the left of profile
	temp = newArray(lengthOf(pattern));
	Array.fill(temp, mean);
	
	if(drawn_Z_or_M == 1){//0 if from (edge to edge)/(Z-disk to Z-disk), 1 if from (center to center)/(M-line-to-M-line)
		if (channel_ZM == "Z") {profileCC = Array.concat(temp, profile);} //1st small portion flat profile of pattern size, rest profile
		else { 	profileCC = Array.slice(profile,round(avgSizeSarcomere/2),profile.length - round(avgSizeSarcomere/2)); //idem, but profile is cut half size of a pattern at both ends
				profileCC = Array.concat(temp,profileCC);}}
	
	else{
		if (channel_ZM == "M") {profileCC = Array.concat(temp, profile);} //1st small portion flat profile of pattern size, rest profile
		else { 	profileCC = Array.slice(profile,round(avgSizeSarcomere/2),profile.length - round(avgSizeSarcomere/2)); //idem, but profile is cut half size of a pattern at both ends
				profileCC = Array.concat(temp,profileCC);}}
	
	
	crossCorrelation = newArray(lengthOf(profileCC)); // initialize array where crosscor will be saved

	//Prepare the pattern to achieve the cross-correlation
	//pads mean value of pattern with profile size at the right of pattern
	if(drawn_Z_or_M == 1){//0 if from (edge to edge)/(Z-disk to Z-disk), 1 if from (center to center)/(M-line-to-M-line)
		if (channel_ZM == "Z") {temp2 = newArray(lengthOf(profile));}
		else {temp2 = newArray(lengthOf(profile)-2*round(avgSizeSarcomere/2));}}
	else{
		if (channel_ZM == "M") {temp2 = newArray(lengthOf(profile));}
		else {temp2 = newArray(lengthOf(profile)-2*round(avgSizeSarcomere/2));}}
	
	Array.fill(temp2, mean);
	
	ln=lengthOf(pattern);//length of the pattern used in cross-correlation
	pattern = Array.concat(pattern, temp2); 

	//Crosscorrelation calculation
	for (m=0; m<lengthOf(profileCC); m++) {
		sum = 0;
		for (n=0; n<lengthOf(profileCC); n++) {
			sum = sum + pattern[n]*profileCC[n];}
		
		crossCorrelation[m] = sum;
		Array.rotate(pattern, 1); // Rotates the array elements by "d" (here 1) steps (positive "d" = rotate right).
		} 
	
	posPattern = newArray();

	//Search for pattern position in the peaks of cross-correlation signal 
	for (i = ln/2; i < lengthOf(crossCorrelation)-ln;i+=0) { 
		start = i;
		end = i+ln-1;

		patt = Array.slice(crossCorrelation, start, end); // Extracts a part of an array and returns it.
		maxi = Array.findMaxima(patt, 30);
		
		if(drawn_Z_or_M == 1){
			if (channel_ZM == "Z") {newpattern_center = round(i +  maxi[0] - ln/2);}
			else {newpattern_center = round(i +  maxi[0] - ln/2 + avgSizeSarcomere/2);}}
		else{
			if (channel_ZM == "M") {newpattern_center = round(i +  maxi[0] - ln/2);}
			else {newpattern_center = round(i +  maxi[0] - ln/2 + avgSizeSarcomere/2);}}
		
		posPattern = Array.concat(posPattern,newpattern_center);
		i = i + maxi[0] + ln/2; //defines start of new window half a pattern size away from the highest peak found.
		}

return posPattern;
}



/////**************************************************************************/////

function Localization(image_folder_name, channel, profile, type, nb_band, avgSizeSarcomere, posPattern, channel_ZM, temp, timelapseID, ROI_number) {
	//temp = 1 will save data in "temp" files, not used in analysis 

	loc = newArray();

	if (type == "q") {//type actin - algorithm quantile

		// step 1: subtract background on the profile, using 20% smallest values into a linear fit (local subtraction of background)
		sortedValues = Array.copy(profile);
		Array.sort(sortedValues);
		threshold = sortedValues[Math.floor((sortedValues.length)*0.2)];
		tofit_y = newArray();
		tofit_x = newArray();
			for (i = 0; i < profile.length; i++) {
				if (profile[i] < threshold) {
					tofit_x = Array.concat(tofit_x, i);
					tofit_y = Array.concat(tofit_y, profile[i]);}}
			linearEquation = "y = a*x + b";
					initialGuesses = newArray(0,0);
					Fit.doFit(linearEquation, tofit_x, tofit_y, initialGuesses);
							a = Fit.p(0);// slope
							b = Fit.p(1);// y at x=0
			for (i = 0; i < profile.length; i++) {
				profile[i] = profile[i] - a*i - b;
			}
			
		// step 2: find pattern edges
			for (m = 0; m < posPattern.length; m++) {
				start_subprofile = maxOf(round(posPattern[m] - avgSizeSarcomere/2),0);
				end_subprofile = minOf(round(posPattern[m] + avgSizeSarcomere/2),profile.length-1);
				subprofile = Array.slice(profile, start_subprofile, end_subprofile);
				
			subloc = actin_edges_finder_quantile_alg(subprofile,start_subprofile);
			loc = Array.concat(loc,subloc);}
		}
	else if (type == "s") {//show the position from cross corr analysis	if type "single pattern" was chosen
		loc = Localization_pattern(posPattern);}
			
	else{
		for (m = 0; m < posPattern.length; m++) {
		//select a portion of the profile, based on the position of pattern found previously
		
			start_subprofile = maxOf(round(posPattern[m] - avgSizeSarcomere/2),0);
			end_subprofile = minOf(round(posPattern[m] + avgSizeSarcomere/2),profile.length-1);
					
			subprofile = Array.slice(profile, start_subprofile, end_subprofile);
		
			//depending on type, it looks for relevant localizations (bands, edges...)
			if (type == "i") {//type individual bands
				subloc = Localization_bands(subprofile, start_subprofile, nb_band);}
				
			else if (type == "v") {//type close individual bands
				subloc = Localization_close_bands(subprofile, start_subprofile, nb_band);}
						
			else if (type == "a") {//type actin - algorithm exponentials combination
				subloc = actin_edges_finder(subprofile,start_subprofile);}
				
			else if (type == "b") {//type block	
					subloc = multiple_block_edges_finder(subprofile, start_subprofile, nb_band);}

			else if (type == "o") {subloc = newArray();}//type other
			
			// in rare cases, fitting functions may give (0) as a result, which is avoided here
			if((subloc.length == 1) & (subloc[0] == 0)){
			loc = loc;}
			else {
			loc = Array.concat(loc,subloc);}
			}}
	
	Saveloc(image_folder_name, channel, type, nb_band, loc, temp, timelapseID, ROI_number);
	
}


		/////**************************************************************************/////
		
		function actin_edges_finder(subprofile,start_subprofile){
		
		//////////////////////////////////////////////////////////////////////
		// defines edges position of actin for a single I-band in a profile //
		//      saved in pattern                                            //
		// pattern_begin is the position in pixels where the pattern begins //
		//////////////////////////////////////////////////////////////////////
		  
			y = subprofile;// data centered on pattern
			x = Array.getSequence(subprofile.length);


			//find z-disk position
				max = Array.findMaxima(y,5); 
				
				// Fit the profile maximum to get subpixel resolution on z-disk position
				start = maxOf(0,max[0] - 5); // max[0] Select the highest peak of the array
				end = minOf(y.length,max[0] + 5);

				small_y = Array.slice(y,start,end); // Extracts a part of an array and returns it. 
				small_x = Array.slice(x,start,end); // Extracts a part of an array and returns it. 
				Fit.doFit("Gaussian", small_x, small_y);
				getPixelSize(unit, pixelWidth, pixelHeight); // Get the pixel unit (set by the program who made the image), the pixel"s width and the pixel height
			
			z_disk_pos = ((Fit.p(2))+start_subprofile)*pixelWidth;
						
			//finding initial rough position of actin edges 
			Array.getStatistics(y, min, maxi, mean, stdDev);
			for (i = 0; i < y.length; i++) {y[i] = y[i]-min;}//sets profile minimum to zero
			
				
			//*** Left side ***//
			left_y = Array.slice(y,0,round(y.length/2)-5);
			left_x = Array.slice(x,0,round(x.length/2)-5);
			simpleexpEquation_increase = "y = a*( 1/(1+exp(-(x-b)/c) ) ) ";
			initialGuesses = newArray(maxi-min, left_x.length/2, (maxi-min)/(left_x.length/2));
			Fit.doFit(simpleexpEquation_increase, left_x, left_y, initialGuesses);
				
			//finds precise location of left and right edge
			posLeft = Fit.p(1);// position of left edge (rough)
			// check that this position is within the right range, otherwise do not extract position
			increase_rate = Fit.p(2);// way the block signal increases at the edge
			leftactin = Array.slice(y, maxOf(0, posLeft-3*increase_rate), minOf(y.length/2, posLeft+3*increase_rate));
			xleftactin = Array.slice(x, maxOf(0, posLeft-3*increase_rate), minOf(y.length/2, posLeft+3*increase_rate));
			
			/// skip rest of the analysis if the rough estimation did not go well
			if (xleftactin.length == 0 || posLeft < 0 || posLeft > round(x.length/2)) {
				analysis = 0;
			}
 
			else {			
				initialGuesses = newArray(maxi-min, posLeft, increase_rate);
				Fit.doFit(simpleexpEquation_increase, xleftactin, leftactin, initialGuesses);
				
				preciseLeft = ((Fit.p(1))+start_subprofile)*pixelWidth;
				rate_left = 1/(Fit.p(2)*pixelWidth);
				
				// Checks that the analysis went well
				if (Fit.p(1) < 0 || Fit.p(1) > round(x.length/2)) {analysis = 0;}
				else {analysis = 1;}}
				

			///*** Right side ***///
			right_y = Array.slice(y,round(y.length/2)+5,y.length-1);
			right_x = Array.slice(x,round(y.length/2)+5,y.length-1);
			simpleexpEquation_decrease = "y = a*( 1/(1+exp((x-b)/c) ) ) ";
			initialGuesses = newArray(maxi-min, x.length*0.75, (maxi-min)/(left_x.length/2));

			Fit.doFit(simpleexpEquation_decrease, right_x, right_y, initialGuesses);

			posRight = Fit.p(1);// position of right edge (rough)
			increase_rate = Fit.p(2);// way the block signal increases at the edge
			rightactin = Array.slice(y, maxOf(y.length/2, posRight-3*increase_rate), minOf(y.length, posRight+3*increase_rate));
			xrightactin = Array.slice(x, maxOf(y.length/2, posRight-3*increase_rate), minOf(y.length, posRight+3*increase_rate));
						
			if ((xrightactin.length == 0) || (posRight < round(y.length/2)) || (posRight > y.length-1)) {
				analysis = 0;
			}
			else {

			initialGuesses = newArray(maxi-min, posRight, increase_rate);
			Fit.doFit(simpleexpEquation_decrease, xrightactin, rightactin, initialGuesses);
			
			preciseRight = ((Fit.p(1))+start_subprofile)*pixelWidth;
			rate_right = 1/(Fit.p(2)*pixelWidth);
			
			// Checks that the analysis went well
			if ((Fit.p(1) < round(y.length/2)) || (Fit.p(1) > y.length-1)) {analysis = 0;}
			else {analysis = 1*analysis;}} //combines the outcome of the left edge with the right edge
		
		if (analysis == 1) {return newArray(preciseLeft, z_disk_pos, preciseRight, rate_left, rate_right);}
		else {// something went wrong during the analysis, so it will be skipped at a later stage
			empty_result = newArray(1);
			empty_result[0] = 0;
			return empty_result;}
		}

		/////**************************************************************************/////
		
		function actin_edges_finder_quantile_alg(subprofile,start_subprofile){
		
		//////////////////////////////////////////////////////////////////////
		// defines edges position of actin for a single I-band in a profile //
		// The algorithm defines fit the z-disk with a gaussian
		// Window edges based on quantiles: the overall shape looks like of block;
		// the bottom of the shape is defined using 20% quantile of the profile
		// with a linear fit. 
		// 
		//////////////////////////////////////////////////////////////////////
		  
			y = subprofile;// data centered on pattern
			x = Array.getSequence(subprofile.length);

			/////find z-disk position
				max = Array.findMaxima(y,5); 
				
				// Fit the profile maximum to get subpixel resolution on z-disk position
				start = maxOf(0,max[0] - 5); // max[0] Select the highest peak of the array
				end = minOf(y.length,max[0] + 5);

				small_y = Array.slice(y,start,end); // Extracts a part of an array and returns it. 
				small_x = Array.slice(x,start,end); // Extracts a part of an array and returns it. 
				Fit.doFit("Gaussian", small_x, small_y);
				getPixelSize(unit, pixelWidth, pixelHeight); // Get the pixel unit (set by the program who made the image), the pixel"s width and the pixel height

				z_disk_pos = ((Fit.p(2))+start_subprofile)*pixelWidth;
			
			//////find position of actin edges 
				
				// Left side
				left_y = Array.slice(y,0,round(y.length/2)-5);
				left_x = Array.slice(x,0,round(x.length/2)-5);

				sortedValues = Array.copy(left_y);
				Array.sort(sortedValues);
				threshold = (sortedValues[Math.floor((sortedValues.length)*0.9)])/2; // threshold at 50% of 90% quantile

				pos_left = newArray();
				for (i = 0; i < left_y.length; i++) {
					if (left_y[i] < threshold) {
						pos_left = Array.concat(pos_left, left_x[i]);
						}
					else{break;}}
				Array.getStatistics(pos_left, min_left, max_left, mean, stdDev);
				leftEdge = (max_left+start_subprofile)*pixelWidth;

				// Right side
				right_y = Array.slice(y,round(y.length/2)+5,y.length-1);
				right_x = Array.slice(x,round(y.length/2)+5,y.length-1);
				sortedValues_right = Array.copy(right_y);
				Array.sort(sortedValues_right);
				threshold = (sortedValues_right[Math.floor((sortedValues_right.length)*0.9)])/2;

				pos_right = newArray();
				for (i = right_y.length-1; i >-1 ; i--) {
					if (right_y[i] < threshold) {
						pos_right = Array.concat(pos_right, right_x[i]);
						}
					else{break;}}
				Array.getStatistics(pos_right, min_right, max_right, mean, stdDev);
				rightEdge = (min_right+start_subprofile)*pixelWidth;
		
		return newArray(leftEdge, z_disk_pos, rightEdge);
		}
		
		/////**************************************************************************/////
		
		function block_edges_finder(subprofile,start_subprofile){
		
		//////////////////////////////////////////////////////////////////////
		// Uses sigmoid functions to find the left and right edge of 
		// a block-shaped pattern                       
		// In each case a rough localization is achieved before a precise fitting
		//////////////////////////////////////////////////////////////////////
		  
			y = subprofile;// data centered on pattern
			x = Array.getSequence(subprofile.length);
			
			//finding initial rough position of block edges 
			Array.getStatistics(y, min, maxi, mean, stdDev);
			for (i = 0; i < y.length; i++) {y[i] = y[i]-min;}//sets profile minimum to zero
				
			//*** Left side ***//
			left_y = Array.slice(y,0,round(y.length/2));
			left_x = Array.slice(x,0,round(x.length/2));
			simpleexpEquation_increase = "y = a*( 1/(1+exp(-(x-b)/c) ) ) ";
			initialGuesses = newArray(maxi-min, left_x.length/2, (maxi-min)/(left_x.length/2));
			Fit.doFit(simpleexpEquation_increase, left_x, left_y, initialGuesses);
				
			//finds precise location of left and right edge
			posLeft = Fit.p(1);// position of left edge (rough)
			// check that this position is within the right range, otherwise do not extract position
			increase_rate = Fit.p(2);// way the block signal increases at the edge
			leftactin = Array.slice(y, maxOf(0, posLeft-3*increase_rate), minOf(y.length/2, posLeft+3*increase_rate));
			xleftactin = Array.slice(x, maxOf(0, posLeft-3*increase_rate), minOf(y.length/2, posLeft+3*increase_rate));
			
			/// skip rest of the analysis if the rough estimation did not go well
			if (xleftactin.length == 0 || posLeft < 0 || posLeft > round(x.length/2)) {
				analysis = 0;
			}
 
			else {			
				initialGuesses = newArray(maxi-min, posLeft, increase_rate);
				Fit.doFit(simpleexpEquation_increase, xleftactin, leftactin, initialGuesses);
				
				preciseLeft = ((Fit.p(1))+start_subprofile)*pixelWidth;
				rate_left = 1/(Fit.p(2)*pixelWidth);
				
				// Checks that the analysis went well
				if (Fit.p(1) < 0 || Fit.p(1) > round(x.length/2)) {analysis = 0;}
				else {analysis = 1;}}
				

			///*** Right side ***///
			right_y = Array.slice(y,round(y.length/2),y.length-1);
			right_x = Array.slice(x,round(y.length/2),y.length-1);
			simpleexpEquation_decrease = "y = a*( 1/(1+exp((x-b)/c) ) ) ";
			initialGuesses = newArray(maxi-min, x.length*0.75, (maxi-min)/(left_x.length/2));

			Fit.doFit(simpleexpEquation_decrease, right_x, right_y, initialGuesses);

			posRight = Fit.p(1);// position of right edge (rough)
			increase_rate = Fit.p(2);// way the block signal increases at the edge
			rightactin = Array.slice(y, maxOf(y.length/2, posRight-3*increase_rate), minOf(y.length, posRight+3*increase_rate));
			xrightactin = Array.slice(x, maxOf(y.length/2, posRight-3*increase_rate), minOf(y.length, posRight+3*increase_rate));
						
			if ((xrightactin.length == 0) || (posRight < round(y.length/2)) || (posRight > y.length-1)) {
				analysis = 0;
			}
			else {

			initialGuesses = newArray(maxi-min, posRight, increase_rate);
			Fit.doFit(simpleexpEquation_decrease, xrightactin, rightactin, initialGuesses);
			
			preciseRight = ((Fit.p(1))+start_subprofile)*pixelWidth;
			rate_right = 1/(Fit.p(2)*pixelWidth);
			
			// Checks that the analysis went well
			if ((Fit.p(1) < round(y.length/2)) || (Fit.p(1) > y.length-1)) {analysis = 0;}
			else {analysis = 1*analysis;}} //combines the outcome of the left edge with the right edge
		
		if (analysis == 1) {return newArray(preciseLeft , preciseRight, rate_left, rate_right);}
		else {// something went wrong during the analysis, so it will be skipped at a later stage
			empty_result = newArray(1);
			empty_result[0] = 0;
			return empty_result;}
		}
		
		
		/////**************************************************************************/////	

		
		function multiple_block_edges_finder(subprofile, start_subprofile, nb_band){	
			
		if (nb_band == 1){
		//////////////////////////////////////////////////////////////////////
		// Uses sigmoid functions to find the left and right edge of 
		// a block-shaped pattern                       
		// In each case a rough localization is achieved before a precise fitting
		//////////////////////////////////////////////////////////////////////
		  
			y = subprofile;// data centered on pattern
			x = Array.getSequence(subprofile.length);
			
			//finding initial rough position of block edges 
			Array.getStatistics(y, min, maxi, mean, stdDev);
			for (i = 0; i < y.length; i++) {y[i] = y[i]-min;}//sets profile minimum to zero
				
			//*** Left side ***//
			left_y = Array.slice(y,0,round(y.length/2));
			left_x = Array.slice(x,0,round(x.length/2));
			simpleexpEquation_increase = "y = a*( 1/(1+exp(-(x-b)/c) ) ) ";
			initialGuesses = newArray(maxi-min, left_x.length/2, (maxi-min)/(left_x.length/2));
			Fit.doFit(simpleexpEquation_increase, left_x, left_y, initialGuesses);
				
			//finds precise location of left and right edge
			posLeft = Fit.p(1);// position of left edge (rough)
			// check that this position is within the right range, otherwise do not extract position
			increase_rate = Fit.p(2);// way the block signal increases at the edge
			leftactin = Array.slice(y, maxOf(0, posLeft-3*increase_rate), minOf(y.length/2, posLeft+3*increase_rate));
			xleftactin = Array.slice(x, maxOf(0, posLeft-3*increase_rate), minOf(y.length/2, posLeft+3*increase_rate));
			
			/// skip rest of the analysis if the rough estimation did not go well
			if (xleftactin.length == 0 || posLeft < 0 || posLeft > round(x.length/2)) {
				analysis = 0;
			}
 
			else {			
				initialGuesses = newArray(maxi-min, posLeft, increase_rate);
				Fit.doFit(simpleexpEquation_increase, xleftactin, leftactin, initialGuesses);
				
				preciseLeft = ((Fit.p(1))+start_subprofile)*pixelWidth;
				rate_left = 1/(Fit.p(2)*pixelWidth);
				
				// Checks that the analysis went well
				if (Fit.p(1) < 0 || Fit.p(1) > round(x.length/2)) {analysis = 0;}
				else {analysis = 1;}}
				

			///*** Right side ***///
			right_y = Array.slice(y,round(y.length/2),y.length-1);
			right_x = Array.slice(x,round(y.length/2),y.length-1);
			simpleexpEquation_decrease = "y = a*( 1/(1+exp((x-b)/c) ) ) ";
			initialGuesses = newArray(maxi-min, x.length*0.75, (maxi-min)/(left_x.length/2));

			Fit.doFit(simpleexpEquation_decrease, right_x, right_y, initialGuesses);

			posRight = Fit.p(1);// position of right edge (rough)
			increase_rate = Fit.p(2);// way the block signal increases at the edge
			rightactin = Array.slice(y, maxOf(y.length/2, posRight-3*increase_rate), minOf(y.length, posRight+3*increase_rate));
			xrightactin = Array.slice(x, maxOf(y.length/2, posRight-3*increase_rate), minOf(y.length, posRight+3*increase_rate));
						
			if ((xrightactin.length == 0) || (posRight < round(y.length/2)) || (posRight > y.length-1)) {
				analysis = 0;
			}
			else {

			initialGuesses = newArray(maxi-min, posRight, increase_rate);
			Fit.doFit(simpleexpEquation_decrease, xrightactin, rightactin, initialGuesses);
			
			preciseRight = ((Fit.p(1))+start_subprofile)*pixelWidth;
			rate_right = 1/(Fit.p(2)*pixelWidth);
			
			// Checks that the analysis went well
			if ((Fit.p(1) < round(y.length/2)) || (Fit.p(1) > y.length-1)) {analysis = 0;}
			else {analysis = 1*analysis;}} //combines the outcome of the left edge with the right edge
		
		///// Check if the previous step was successful
		
		if (analysis == 1) {return newArray(preciseLeft , preciseRight, rate_left, rate_right);}
		else {// something went wrong during the analysis, so it will be skipped at a later stage
			empty_result = newArray(1);
			empty_result[0] = 0;
			return empty_result;}
	}
			
	else{	
		
		
			//////////////////////////////////////////////////////////////////////
			// multistep algorithm to find block edges
			// 1. uses watersheding on the inversed pattern until the number of blocks are found
			// 2. uses sigmoid functions to find the left and right edges of the different blocks
			//////////////////////////////////////////////////////////////////////
			  
				y = subprofile;// data centered on pattern
				x = Array.getSequence(subprofile.length);
				
				//finding initial rough position of blocks with watersheding 
				Array.getStatistics(y, min, max, mean, stdDev);
				for (i = 0; i < y.length; i++) {y[i] = (y[i]-min)/(max-min);}//sets profile minimum to zero and normalize it to 1
				Array.getStatistics(y, min, maxi, y_mean, stdDev);
				
				copy_y = Array.copy(y);
				y_sorted = Array.sort(copy_y);			
				y_median = y_sorted[round(y.length/4)];
				threshold = y_mean;// + (1-y_mean)/2; // adjust to the most robust value
				
				watershed = newArray(y.length);
					for (i = 0; i < y.length; i++) {
						if(y[i] >= threshold){watershed[i] = 1;}	
						else {watershed[i] = 0;}	
					}
				
				// compute the position of blocks limits using the fact that a left edge goes from 0 to 1 and right edge from 1 to 0 
				diff_watershed = newArray(y.length-1);
					for (i = 0; i < y.length-1; i++) {
						diff_watershed[i] = watershed[i+1] - watershed[i];
					}
					
				step_up = newArray(0);
				step_down = newArray(0);
				
				for (i = 0; i < y.length-1; i++) {
					if(diff_watershed[i] == 1){
						step_up = Array.concat(step_up, i);
					}
					else if(diff_watershed[i] == -1){
						step_down = Array.concat(step_down, i);
					}
				}
	
				///// Check if the previous step was successful
				if(step_up.length == 0 || step_down.length == 0){
					// something went wrong during the analysis, so it will be skipped at a later stage
					empty_result = newArray(1);
					empty_result[0] = 0;
					return empty_result;
				}
				
				else{
					// avoid step down before step up at the very beginning of pattern
					if(step_up[0] > step_down[0]){step_down = Array.slice(step_down, 1, step_down.length-1);}
					
					// avoid step up after step down at the very end of pattern
					if(step_up[step_up.length-1] > step_down[step_down.length-1]){step_up = Array.trim(step_up, step_up.length-1);}
					
									
					///// Check if the previous step was successful
					if(step_up.length == 0 || step_down.length == 0){
						// something went wrong during the analysis, so it will be skipped at a later stage
						empty_result = newArray(1);
						empty_result[0] = 0;
						return empty_result;
					}	
					
					else {
						//search for blocks
						// search for the largest blocks
						block_size = newArray(step_up.length);
						
						for (i = 0; i < step_up.length; i++) {
							block_size[i] = step_down[i] - step_up[i];
						}

						///// Check if the previous step was successful (enough blocks compared to what is expected
						if(block_size.length < nb_band){
							// something went wrong during the analysis, so it will be skipped at a later stage
							empty_result = newArray(1);
							empty_result[0] = 0;
							return empty_result;
						}
					
						else{block_size_copy = Array.copy(block_size);
							sorted_block_size = Array.sort(block_size_copy);
							
							// keep the nb_band-th highest values
							relevant_block = Array.trim(Array.reverse(sorted_block_size),nb_band);
							
							// match largest blocks to their positions
							relevant_position = newArray(nb_band);
							k = 0;
							for (i = 0; i < nb_band; i++) {
								ref_size = relevant_block[i];
								for (j = 0; j < step_up.length; j++) {
									if (ref_size == block_size[j]){
										position = j;
										Array.deleteIndex(block_size, j);
										relevant_position[k] = position; k++;}
									}
								}
							
							
							//define blocks based on found positions
							left_blocks = newArray(nb_band);
							right_blocks = newArray(nb_band);
							for (i = 0; i < left_blocks.length; i++) {
								left_blocks[i] = step_up[relevant_position[i]];
								right_blocks[i] = step_down[relevant_position[i]];}
								
							// start fitting based on left and right position of block and the block size with "relevant_block"
							
							preciseLeft = newArray(nb_band);
							rateLeft = newArray(nb_band);
							preciseRight = newArray(nb_band);
							rateRight = newArray(nb_band);
							
							for (i = 0; i < nb_band; i++) {
								size = relevant_block[i];
								if(size < 3){analysis == 0;}
								else{	index_left = maxOf(0, round(left_blocks[i]-size/4));
										index_right = minOf(round(left_blocks[i]+size/2), y.length-1);
										left_y = Array.slice(y, index_left, index_right);
										left_x = Array.slice(x, index_left, index_right);
										simpleexpEquation_increase = "y = a*( 1/(1+exp(-(x-b)/c) ) ) ";
										initialGuesses = newArray(1, left_blocks[i], 1/(size/4)); // amplitude, position, rate
										
										Fit.doFit(simpleexpEquation_increase, left_x, left_y, initialGuesses);
								
								// check that everything is ok
								if (Fit.p(1) < x[index_left] || Fit.p(1) > x[index_right]) {analysis = 0;}
								else {	preciseLeft[i] = (Fit.p(1)+start_subprofile)*pixelWidth;
										rateLeft[i] = Fit.p(2)*pixelWidth;
										if (i == 0){analysis = 1;}
										else {analysis = analysis;}}
							}}
							
							if(analysis == 1){
							for (i = 0; i < nb_band; i++) {
								size = relevant_block[i];
								if(size < 3){analysis == 0;}
								else{
								index_left = maxOf(0, round(right_blocks[i]-size/2));
								index_right = minOf(round(round(right_blocks[i]+size/4)), y.length-1);
								right_y = Array.slice(y, index_left, index_right);
								right_x = Array.slice(x, index_left, index_right);
								simpleexpEquation_decrease = "y = a*( 1/(1+exp((x-b)/c) ) ) ";
								initialGuesses = newArray(1, right_blocks[i], 1/(size/4));
				
								Fit.doFit(simpleexpEquation_decrease, right_x, right_y, initialGuesses);
								
								// check that everything is ok
								if (Fit.p(1) < x[index_left] || Fit.p(1) > x[index_right]) {analysis = 0;}
								else {	preciseRight[i] = (Fit.p(1)+start_subprofile)*pixelWidth;
										rateRight[i] = Fit.p(2)*pixelWidth;
										analysis = analysis;}
							}}}
							
						Result = Array.concat(preciseLeft, preciseRight, rateLeft, rateRight);
						
						if (analysis == 1) {return Result;}
						else {// something went wrong during the analysis, so it will be skipped at a later stage
							empty_result = newArray(1);
							empty_result[0] = 0;
							return empty_result;}
						}}}
				}}
		}
		
		/////**************************************************************************/////


		function Localization_bands(subprofile,start_subprofile,nb_band){
		
		//////////////////////////////////////////////////////////////////////
		// 				Finds bands as maxima in profile  		 			//
		//					(number of bands defined by user) 				//
		// 				and then fit each maxima +- 3 pixels 				//
		//					with a gaussian function 						//
		//////////////////////////////////////////////////////////////////////
		  
			y = subprofile;// data centered on pattern
			x = Array.getSequence(subprofile.length);
			
			//find rough band positions
			max_raw = Array.findMaxima(y,1); // second argument is the minimum difference between peaks

			// Rejects max found on edges of the selection
			max = newArray(nb_band);
			k = 0;
			for (i = 0; i < max_raw.length; i++) {
				if ((max_raw[i] != 0) && (max_raw[i] != subprofile.length-1)) {
					max[k] = max_raw[i];
					k = k + 1;
					if (k == nb_band) {break;}}}
			
			subloc = newArray(nb_band);
			
			for (i = 0; i < nb_band; i++) {
				// Fit profile maxima to get subpixel resolution on its position. Use peaks at least a few pixels away from the edge to have enough to fit.
				if(max[i] - 3 > -1){start = max[i] - 3;}
				else {start = max[i] - 2;}
				
				if( max[i] + 3 <subprofile.length+1){end = max[i] + 3;}
				else {end = max[i] + 2;}
	
				if (start>-1 && end<subprofile.length+1) {
				
					small_y = Array.slice(y,start,end); // Extracts the region around the local maximum 
					small_x = Array.slice(x,start,end); 
					Fit.doFit("Gaussian", small_x, small_y); // fit the position of the local maximum

					//get the position in units used in the image (ie µm, mm...)
					getPixelSize(unit, pixelWidth, pixelHeight);
					if (Fit.p(2)>max[i] + 3 || Fit.p(2)<max[i] - 3) {subloc[i] = (max[i] + start_subprofile)*pixelWidth;}
					else {	subloc[i] = (Fit.p(2) + start_subprofile)*pixelWidth;}
			}}

		return Array.sort(subloc);
		}
		
		/////**************************************************************************/////


		function Localization_close_bands(subprofile,start_subprofile,nb_band){
		
		//////////////////////////////////////////////////////////////////////
		// 				Finds bands as maxima in profile  		 			//
		//					(number of bands defined by user) 				//
		// 				and then fit each maxima +- 1 pixels 				//
		//					with a gaussian function 						//
		//				!!! Specific for very close bands !!!				//
		//////////////////////////////////////////////////////////////////////
		  
			y = subprofile;// data centered on pattern
			x = Array.getSequence(subprofile.length);
			
			
			//find rough band positions
			max = Array.findMaxima(y,1); // second argument is the minimum difference between peaks
			
			if(max.length >=  nb_band){
				subloc = newArray(nb_band);
				
				for (i = 0; i < nb_band; i++) {
					// Fit profile maxima to get subpixel resolution on its position
					start = max[i] - 1;
					end = max[i] + 1;
	
					if (start>-1 && end<subprofile.length+1) {
					
						small_y = Array.slice(y,start,end); // Extracts the region around the local maximum 
						small_x = Array.slice(x,start,end); 
						Fit.doFit("Gaussian", small_x, small_y);  // fit the position of the local maximum
			
						getPixelSize(unit, pixelWidth, pixelHeight);
						
						//get the position in units used in the image (ie µm, mm...)
						if (Fit.p(2)>max[i] + 1 || Fit.p(2)<max[i] - 1) {subloc[i] = (max[i] + start_subprofile)*pixelWidth;}
						else {	subloc[i] = (Fit.p(2)+start_subprofile)*pixelWidth;}
					}
				}
				
			
				return Array.sort(subloc);}
			else{
				empty_result = newArray(1);
				empty_result[0] = 0;
				return empty_result;}
		}
		
		/////**************************************************************************/////

		function Localization_pattern(posPattern){
		
		//////////////////////////////////////////////////////////////////////
		// 		   Use the ouput of the crosscorrelation as position		//
		//					       											//
		//				!!! not precise (but useful) !!!					//
		//////////////////////////////////////////////////////////////////////
		  
		subloc = newArray(posPattern.length);
		getPixelSize(unit, pixelWidth, pixelHeight);
		for (i = 0; i < posPattern.length; i++) {
			subloc[i] = posPattern[i]*pixelWidth;
		}

		return Array.sort(subloc);
		}

		/////**************************************************************************/////
		
		function Saveloc(image_folder_name, channel, type, nb_band, loc, temp, ROI_or_timelapseID, ROI_number)
		//temp = 1 will save data in "temp" files, not used in analysis, temp = 2 will save files for timelapse
		{
			if(temp == 0){
				imagenumber = getTitle();// get the title of the image
							
				//Check how many ROI have already been used on the image to pick the right name
				i = 1;
				j = 1;
				  while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities" + File.separator + imagenumber +
				  						"_2D_profile_channel1_" + i +".txt")==1)
				{    
				     i = i + 1;
				      j = i;  } //keep j as the increment to use
	
				File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + imagenumber +
									"_localizations_channel_" + channel + "_" + j +".txt");
				f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + imagenumber +
								"_localizations_channel_" + channel + "_" + j +".txt");}

			else if(temp == 2){// for timelapses
				imagenumber = getTitle();// get the title of the image
				
				// Creates the timelapse "internal" folder if necessary 
				if (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal")!=1) {
				File.makeDirectory(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal");}
				//Check how many ROI have already been used on the image to pick the right name
				i = 1;
				j = 1;
				  while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal" + File.separator + imagenumber + 
				  						"_localizations_channel_" + channel + "_timelapse_" + ROI_or_timelapseID + "_t_" + i +".txt")==1)
					{ i = i + 1;
				      j = i;  } //keep j as the increment to use
				      
				loc_file_path = image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal" + File.separator + imagenumber +
									"_localizations_channel_" + channel + "_timelapse_" + ROI_or_timelapseID + "_t_" + j +".txt";
									
				File.saveString("", loc_file_path);
				f = File.open(loc_file_path);}
				
			else if(temp == 3){
				imagenumber = getTitle();// get the title of the image
				
				File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + 
									imagenumber +"_ROI_" + ROI_or_timelapseID + "_localizations_channel_" + channel + "_" + ROI_number +".txt");
									
				f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + 
								imagenumber + "_ROI_" + ROI_or_timelapseID + "_localizations_channel_" + channel + "_" + ROI_number +".txt");}
				

			else{File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "temp_localizations_channel_" + channel + ".txt");
				f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "temp_localizations_channel_" + channel + ".txt");}


			if (type == "i") {//type individual bands
				for (i = 0; i < loc.length/nb_band ; i++) {
					string="";
					for (k = 0; k < nb_band; k++) {
						if (k==0) {
			                string=string+loc[i*nb_band+k];}
			            else {
			                string=string+"\t"+loc[i*nb_band+k];}}
	        print(f, string);
					}
				}
				
			else if (type == "v") {//type individual bands
				for (i = 0; i < loc.length/nb_band ; i++) {
					string="";
					for (k = 0; k < nb_band; k++) {
						if (k==0) {
			                string=string+loc[i*nb_band+k];}
			            else {
			                string=string+"\t"+loc[i*nb_band+k];}}
	        print(f, string);
					}
				}
				
			else if (type == "s") {//single band / cross corr
				nb_band = 1;
				for (i = 0; i < loc.length/nb_band ; i++) {
					string="";
					for (k = 0; k < nb_band; k++) {
						if (k==0) {
			                string=string+loc[i*nb_band+k];}
			            else {
			                string=string+"\t"+loc[i*nb_band+k];}}
	        print(f, string);
					}
				}
						
			else if (type == "a") {//type actin	exponential algorithm
				for (i = 0; i < loc.length/5 ; i++) {
					string="";
					for (k = 0; k < 5; k++) {
						if (k==0) {
			                string=string+loc[i*5+k];}
			            else {
			                string=string+"\t"+loc[i*5+k];}}
	        print(f, string);
					}
				}

			else if (type == "q") {//type actin quantile algorithm
				for (i = 0; i < loc.length/3 ; i++) {
					string="";
					for (k = 0; k < 3; k++) {
						if (k==0) {
			                string=string+loc[i*3+k];}
			            else {
			                string=string+"\t"+loc[i*3+k];}}
	        print(f, string);
					}
				}
				
			else if (type == "b")  {//type block	
				for (i = 0; i < loc.length/(4*nb_band) ; i++) {
					string="";
					for (k = 0; k < 4*nb_band; k++) {
						if (k==0) {
			                string=string+loc[i*4*nb_band+k];}
			            else {
			                string=string+"\t"+loc[i*4*nb_band+k];}}
	        print(f, string);
					}
				}	
			else if (type == "o") {}//type other
	
			File.close(f);

		}


/////**************************************************************************/////

function AskForAnalysis(types, bands) {
		
	//*** Open Dialog to ask user what analysis to carry out ***//


	Dialog.createNonBlocking("Analysis");
	Dialog.addMessage("Please provide some information \non your analysis", 15, "#0000ff");

	//Dialog.addNumber("Which channel should be used as reference?", 1);

			Choices = newArray(types.length);
	for (i = 0; i < types.length; i++) {
			Choices[i] = toString(i+1);
			}

	Dialog.addChoice("Which channel should be used as reference?:", Choices);
	
	Dialog.addMessage("(this channel will be used to define the pattern/sarcomere length)");
		
	Dialog.show;

		  ref_channel = Dialog.getChoice();//Dialog.getNumber();

	return ref_channel;
	}



/////**************************************************************************/////

function Save_sarcomere_length_data(image_folder_name, imagenames, refchannel, types, nb_bands){
	//returns string with filename1 \n sarcomere length \n x number of zdisk-1, filename2 \n etc...

	sarcomere_for_concatenated_data = "filename	selection	repeats	pattern_or_sarcomere_length"+"\n";
	sarcomere_length = newArray();
	references = newArray();
	//channel specify which channel is used as reference
	
			//open files and extract data

	for (i = 0; i < imagenames.length; i++) {
		k = 1;
		while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + imagenames[i] +
							"_localizations_channel_" + refchannel + "_" + k +".txt")==1)
			{
			localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator +
													imagenames[i] + "_localizations_channel_" + refchannel + "_" + k +".txt");

			rows=split(localization_file, "\n");
			refs = newArray(rows.length);
			sub_sarcomere_length = newArray(rows.length-1);
			
			for(m=0; m<rows.length; m++){
				elements=split(rows[m],"\t");
				
				if ((types[refchannel-1] == "a") || (types[refchannel-1] == "q")) {refs[m] = parseFloat(elements[1]);}// peak in center of actin pattern profile
				
				else if ( (types[refchannel-1] == "i") || (types[refchannel-1] == "v") || (types[refchannel-1] == "s") ){
					//mean in array statistics give the average position of bands, used here as the reference
					Array.getStatistics(elements, min, max, ref_position, stdDev);
					refs[m] = ref_position;}
					
				else if (types[refchannel-1] == "b"){
					Array.getStatistics(Array.trim(elements, elements.length/2), min, max, ref_position, stdDev);//average of positions
					refs[m] = ref_position;}
					
				else{Dialog.create("There is a problem...");
					Dialog.addMessage("Only band(s) type of data can be used as a reference");
					Dialog.show;
					break;}
				}
					
			//sarcomere_for_concatenated_data = sarcomere_for_concatenated_data + "\t" + imagenames[i] + "_localizations_channel_" + refchannel + "_" + k +"\n";
				
			for(m=0; m<rows.length-1; m++){
				sub_sarcomere_length[m] = refs[m+1] - refs[m];
				sarcomere_for_concatenated_data = sarcomere_for_concatenated_data + imagenames[i] +"\t"+ toString(k) +"\t"+  toString(m+1) +
													"-" + toString(m+2) +"\t"+ toString(sub_sarcomere_length[m]) + "\n";}
				
			sarcomere_for_concatenated_data = sarcomere_for_concatenated_data;//adds a line each time it changes to another file
			sarcomere_length = Array.concat(sarcomere_length,sub_sarcomere_length);
			references = Array.concat(references,refs);
			k = k + 1;
					}
			}


	//save sarcomere length in a single file
	File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "pattern_or_sarcomere_lengths.txt")
	f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "pattern_or_sarcomere_lengths.txt");
	print(f,sarcomere_for_concatenated_data);

	File.close(f);
	
	// displays an histogram of sarcomere/pattern lengths
	requires("1.52f");
	Plot.create("Histogram of lengths", "Length", "Frequency");
	binWidth = 0;//use 0 for auto-binning
	    binCenter = 0;
	    Plot.setColor("#6a919a", "#6a919a");
	Plot.addHistogram(sarcomere_length, binWidth, binCenter );
	
	Array.getStatistics(sarcomere_length, min, max, mean_size, stdDev_size);
	
	mean_and_sd = "Mean size " + toString(mean_size) + ", Std dev " + toString(stdDev_size);
	
	Plot.setColor("#35484d", "#35484d");
	
	Plot.addText(mean_and_sd, 0, 0)
	Plot.setLimits(NaN, NaN, 0, NaN);
	Plot.getLimits(xMin, xMax, yMin, yMax);
	Plot.setLimits(xMin - (xMax-xMin)/10, xMax + (xMax-xMin)/10, yMin, yMax + (yMax-yMin)/10);
	Plot.show();
			
	
	return sarcomere_for_concatenated_data;	
	}

/////**************************************************************************/////


function Concatenated_data(image_folder_name, imagenames, types, bands, sarcomere_for_concatenated_data){
	//Concatenate data from all files and save it in a single file per channel
	
	// first a heading to describe data
	// reminder "individual band(s)", "actin (exp. alg.)", "actin (quant. alg.)", "block", "very close individual band(s)", "single pattern", "other?")
	// with types in "iaqbvso"
	
	for (i = 0; i < types.length; i++) {
		heading = "filename	selection	pattern"+"\t";
		analyzed_type = "iaqbvs";
		if ( analyzed_type.indexOf(types[i]) > -1) { //checks that the type of a given channel is within what can be analyzed
			chan_analyzed = i + 1;
			ch = "ch" + chan_analyzed;
			
			subtype_band = "iv";
			if (subtype_band.indexOf(types[i]) > -1){ // individuals bands or very close individual bands
				for (m = 0; m < bands[i]; m++) {
					b = m + 1;
					if (b == bands[i]){heading = heading + ch + "_band" + b + "\n";}
					else {heading = heading + ch + "_band" + b + "\t";}
					}}
					
			else if (types[i]=="a"){heading = heading + ch + "_left_edge" +"\t" + ch + "_highest" + "\t" + ch + "_right_edge" +"\t" + ch + "_rate_left" + "\t" + ch + "_rate_right" + "\n";}
			else if (types[i]=="q"){heading = heading + ch + "_left_edge" +"\t" + ch + "_highest" + "\t" + ch + "_right_edge" + "\n";}
			
			else if (types[i]=="b"){
				for (m = 0; m < bands[i]; m++) {
					b = m + 1; heading = heading + ch + "_left_edge" + b + "\t";}
				for (m = 0; m < bands[i]; m++) {
					b = m + 1; heading = heading + ch + "_right_edge" + b + "\t";}
				for (m = 0; m < bands[i]; m++) {
					b = m + 1; heading = heading + ch + "_rate_left_edge" + b + "\t";}
				for (m = 0; m < bands[i]; m++) {
					b = m + 1;
					if (b == bands[i]){heading = heading + ch + "_rate_right_edge" + b + "\n";}
					else {heading = heading + ch + "_rate_left_edge" + b + "\t";}
					}}
			
			else if (types[i]=="s"){heading = heading + ch + "_pattern_position" + "\n";}
			}
		
		concat_data = heading;
		
		// then populates the next lines with results
		for (k = 0; k < imagenames.length; k++) {
			// opens a given image_name
				// opens a given selection
					// opens a given channel
					l = 1;
					while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator  + "internal" + File.separator + imagenames[k] + "_localizations_channel_"
											+ chan_analyzed + "_" + l +".txt")==1)
						{
						localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator  + "internal" + File.separator + imagenames[k] +
																"_localizations_channel_" + chan_analyzed + "_" + l +".txt");
						rows=split(localization_file, "\n"); 
						
						for (m = 0; m < rows.length; m++) {
							pattern_number = m + 1;
							concat_data = concat_data + imagenames[k] + "\t" + l + "\t" + pattern_number + "\t" + rows[m] + "\n";
						}
						l = l + 1;}
					}
		
		// Saves the file	
		File.saveString(concat_data, image_folder_name + File.separator + "Analyses" + File.separator + "All_localizations_channel_" + chan_analyzed + ".txt");				
										}
		}
	


/////**************************************************************************/////

function CheckimageStatus(image_folder_name){
	/// Explain use of function
	
	imagenumber = getTitle();
	
	if (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt")!=1) {
		File.saveString(imagenumber + "\n", image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt");}

	else {
		//Open image name file
	image_name_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt");

	//Rows into an array of strings
	rows=split(image_name_file, "\n"); 

	add_image = 0;
	for (i = 0; i < rows.length; i++) {
	if (imagenumber == rows[i]) {add_image = add_image + 1;}
	}

	if (add_image == 0) {
	File.append(imagenumber + "\n", image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt");	}
	}
}

/////**************************************************************************/////

function CheckimageNames(image_folder_name){
	
	if (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt")!=1) {
			Dialog.create("There is a problem...");
			Dialog.addMessage("No analysis can be found");
			Dialog.show;}

	else {
		//Open image name file
	image_name_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt");

	//Rows into an array of strings
	imagenames=split(image_name_file, "\n"); 

	return imagenames;}
}
	

/////**************************************************************************/////

function Position_in_plot_adder(image_folder_name,imagenumber,types, pixelWidth, temp) {//temp = 1 will use "temp" files
	
	///*** Plot the positions extracted in profiles in the profile graph ***///
	
	Roi_patternJ_manager(image_folder_name,imagenumber,types, pixelWidth, temp);
	
	Stack.getDimensions(width, height, channels, slices, frames);

	// sets graph colors 
	    Plotcolors = newArray(channels);
		Imagecolors = "";
		
	    if (channels > 1) {
	        for(c=1; c<channels+1; c++){
	            
	            Stack.setChannel(c);
	        
	            getLut(reds, greens, blues);
	            
	            Imagecolors = Imagecolors + String.join(reds) + "\n" + String.join(greens) + "\n"+ String.join(blues) + "\n";
	            
	            R = toHex(reds[reds.length-1]);
	            G = toHex(greens[greens.length-1]);
	            B = toHex(blues[blues.length-1]);
	
	        	// makes sure there is no white graph, and gives darker colors for most used colors
	            if(R=="ff" && G=="ff" && B == "ff"){R="03"; G="03"; B="03";}
	            if(R=="0" && G=="ff" && B == "0"){R="00"; G="88"; B="00";}
	            if(R=="ff" && G=="0" && B == "0"){R="aa"; G="00"; B="00";}
	            if(R=="0" && G=="0" && B == "ff"){R="00"; G="00"; B="99";}
	            if(R=="ff" && G=="0" && B == "ff"){R="aa"; G="00"; B="99";}
	            if(R=="0"){R="00";}
	            if(G=="0"){G="00";}
	            if(B=="0"){B="00";}
	        
	            Plotcolors[c-1] = "#" + R + G + B;
	            }
	        File.saveString(Imagecolors, image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "colors.txt");
	        }
	     else {
	     		Plotcolors[0] = "#aa0000";}
	
	// plot positions found
	
	for (i = 0; i < types.length; i++) {
				Plot.setColor(Plotcolors[i]);

			if (temp == 0) {
				imagenumber = getTitle();// get the title of the image
					//Check how many ROI have already been used on the image to pick the right name
				k = 1;
				j = 1;
				
				while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + imagenumber + "_localizations_channel_1_" + k +".txt")==1)
					{j = k;
					k = k + 1;} //keep j as the increment to use
				      chann = i + 1;
				localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" +  File.separator + "internal" + File.separator + imagenumber +
														"_localizations_channel_" + chann + "_" + j +".txt");}
			
			else {
				chann = i + 1;
				localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "temp_localizations_channel_" + chann + ".txt");
				
				//File.delete gives "1" as an output when deleting a file, which is shown in log, unless stored in a variable, hence the following line
				temp_value_to_avoid_output_of_function = File.delete(image_folder_name + File.separator + "Analyses" + File.separator + "temp_localizations_channel_" + chann + ".txt"); }
				
			rows=split(localization_file, "\n");
			
			if (rows.length == 0) {//finds an empty result
				Dialog.create("There is a problem...");
				Dialog.addMessage("Sorry, I cannot fit your data.");
				Dialog.addMessage("Consider trying another selection or one of the other fitting methods.");
				Dialog.show;
				exit;
			}
			
			else {
				for(m=0; m<rows.length; m++){
					elements=split(rows[m],"\t");
					if ((types[i] == "i") | (types[i] == "q") | (types[i] == "v")| (types[i] == "s")) {//type individual bands or type actin quantile algorithm
						end = elements.length;}
	
					else if (types[i] == "a") {//type actin
						end = 3;}
	
					else if (types[i] == "b") {//type individual block
						end = elements.length/2;}
						
						for (l = 0; l < end; l++) {
							x1 = 1/pixelWidth*elements[l];
							xValues = newArray(x1,x1);
							yValues = newArray(channels-1-i,channels-i);
							Plot.add( "line", xValues, yValues);}
							}
						}
			}}




/////**************************************************************************/////

function Roi_patternJ_manager(image_folder_name,imagenumber,types, pixelWidth, temp) {//temp = 1 will use "temp" files
	///*** Add the selection to the ROI manager and save the selection ***///
	///* used only when the user chooses to save the results of the analysis *///
	
	if (temp == 0){
		
	//First check if a selection was ever saved for this image. If not then if the ROI manager is not empty, ask the user if it can empty it
		roi_file_path = image_folder_name + File.separator + "Analyses" + File.separator + "ROIset.zip";
		if(File.exists(roi_file_path)){
			roiManager("reset");
			roiManager("open", roi_file_path);
			roiManager("add");
			name = "selection_" + toString(roiManager("size")) + "_" + RoiManager.getName(roiManager("size")-1);
			roiManager("select", roiManager("size")-1);
			roiManager("rename", name);
			Stack.getPosition(channel, slice, frame);
			Roi.setPosition(channel, slice, frame);
			roiManager("save", roi_file_path);
		}
		else{
			if(roiManager("size") > 0){
				
				// ask the user if the ROI manager can be emptied
				showMessageWithCancel("The ROI manager is not empty...", "It seems like your ROI manager is not empty.\n"+
										"Is it ok for you if I delete the current selection(s) from the ROI manager?\n \n" +
				"If you used PatternJ on a previous image, selections are already saved.\nI just make some space for the new image: simply press \"OK\".\n \n" +
				"If these selections are not from PatternJ, you want to keep them\nbut did not save them yet, press \"Cancel\"");
				
				roiManager("reset");//deletes all current selections
				//rename the selection and save
				roiManager("add");
				name = "selection_1_" + RoiManager.getName(roiManager("size")-1);
				roiManager("select", 0);
				roiManager("rename", name);
				Stack.getPosition(channel, slice, frame);
				Roi.setPosition(channel, slice, frame);
				roiManager("deselect");
				roiManager("save", roi_file_path);
				}
			else{
				roiManager("add");
				name = "selection_1_" + RoiManager.getName(roiManager("size")-1);
				roiManager("select", 0);
				roiManager("rename", name);
				Stack.getPosition(channel, slice, frame);
				Roi.setPosition(channel, slice, frame);
				roiManager("deselect");
				roiManager("save", roi_file_path);
			}
			}
	}
}

/////**************************************************************************/////


function SaveROI(){
//Save the 2D intensity information of the ROI
	
	if (File.exists(image_folder_name + File.separator + "Analyses"+ File.separator + "ROI_intensities")!=1) {
			File.makeDirectory(image_folder_name + File.separator + "Analyses"+ File.separator + "ROI_intensities");}
	
	imagenumber = getTitle();// get the title of the image
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(current_channel, slice, frame);			
	
	//Check how many ROI have already been used on the image to pick the right name
	i = 1;
	j = 1;
	  while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities"+ File.separator + imagenumber + "_2D_profile_channel1_" + i +".txt")==1)
	{    
	     i = i + 1;
	      j = i;  } //keep j as the increment to use
	
	run("Interpolate", "interval=1 smooth");    //interpolate the ROI with 1 pixel
	Roi.getCoordinates(x,y);    //get the positions of each point
	
	////// Local segments perpendicular to the junction are used to obtain the profile perpendicular to the segment drawn by the user, every pixel along the segment
	
	getLine(x1, y1, x2, y2, lineWidth); //get the linewidth used
	
	for (i=1; i<channels + 1; i++)
	{    if (channels > 1) {Stack.setChannel(i);}
	
	// create file for profile on channel i
	File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities"+ File.separator + imagenumber + "_2D_profile_channel" + i + "_" + j +".txt")
	
	    f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities"+ File.separator + imagenumber + "_2D_profile_channel" + i + "_" + j +".txt");
	
	// create unitary segments to define profiles perpendicular to the segment drawn
	   for (k=0; k<lengthOf(x)-2; k++)
	    {        if (k<3) {
	            norm = sqrt((x[0]-x[6])*(x[0]-x[6])+(y[0]-y[6])*(y[0]-y[6]));
	            unit_perp_x = (-(y[6]-y[0])/norm);
	            unit_perp_y = ((x[6]-x[0])/norm);
	            }
	            else if (k>lengthOf(x)-4) {
	            norm = sqrt((x[lengthOf(x)-7]-x[lengthOf(x)-1])*(x[lengthOf(x)-7]-x[lengthOf(x)-1])+(y[lengthOf(x)-7]-y[lengthOf(x)-1])*(y[lengthOf(x)-7]-y[lengthOf(x)-1]));
	            unit_perp_x = (-(y[lengthOf(x)-1]-y[lengthOf(x)-7])/norm);
	            unit_perp_y = ((x[lengthOf(x)-1]-x[lengthOf(x)-7])/norm);
	            }
	            else {
	            norm = sqrt((x[k-3]-x[k+3])*(x[k-3]-x[k+3])+(y[k-3]-y[k+3])*(y[k-3]-y[k+3]));
	            unit_perp_x = (-(y[k+3]-y[k-3])/norm);
	            unit_perp_y = ((x[k+3]-x[k-3])/norm);
	            }
	                        
	        // From the reference line, creates a segment (profile line) whose middle is a given point of the reference line,
	        // its length is the linewidth and  it is locally perpendicular to the reference line
	        if(lineWidth == 0){lineWidth = 1;}
	        lengthofprofile = lineWidth;
	        profile=newArray(lengthofprofile);
	
	        for (l=0; l<lengthOf(profile); l++)
	        {    //interpolation of the value of pixel along the profile line
	            xM = x[k] + (l-(lengthOf(profile)-1)/2)*unit_perp_x;
	            yM = y[k] + (l-(lengthOf(profile)-1)/2)*unit_perp_y;
	
	            espilon_x = (xM-floor(xM));
	            espilon_y = (yM-floor(yM));
	                        
	            profile[l] = (1-espilon_x)*(1-espilon_y)*getPixel(floor(xM),floor(yM))
	                        +(espilon_x)*(1-espilon_y)*getPixel(floor(xM)+1,floor(yM))
	                        +(espilon_x)*(espilon_y)*getPixel(floor(xM)+1,floor(yM)+1)
	                        +(1-espilon_x)*(espilon_y)*getPixel(floor(xM),floor(yM)+1);
	        }
	
	        string="";
	        for (l=0; l<lengthOf(profile); l++) {
	            if (l==0) {
	                string=string+profile[l];
	            }
	            else {
	                string=string+"\t"+profile[l];
	            }
	            
	        }
	        print(f, string);
	      }
	    File.close(f);
	}
	if (channels > 1) {Stack.setChannel(current_channel);}
	}

/////**************************************************************************/////

function Display_average_pattern(image_folder_name, ref_channel, imagenames, types){
	
/// Display an image of the average pattern. NB: patterns that are too small (on the edges of a selection only)	are taken into account.

	/// gets pixel size from metadata
		metadata = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "metadata.txt");
		rows = split(metadata, "\n");
		elements=split(rows[rows.length-1],"=");
		pixelsize = parseFloat(elements[1]);
	
	/// gets the median pattern size in pixels from the analysis
		patterns_sizes_string = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "pattern_or_sarcomere_lengths.txt");
		rows = split(patterns_sizes_string, "\n");
		patterns_sizes = newArray(rows.length);
		for (i = 1; i < rows.length; i++) {// first line in file is heading, so it is skipped
			sarc_length = split(rows[i], "\t");
			patterns_sizes[i] = parseFloat(sarc_length[3]);
			}
		patterns_sizes = Array.sort(patterns_sizes);
		median_pattern_size_in_pixels = Math.ceil((patterns_sizes[Math.ceil(rows.length/2-1)]+patterns_sizes[Math.floor(rows.length/2-1)])/(2*pixelsize));
		//ceil and floor ensure that median def is used. The median is then ceiled

	// extracts the height of the selection in pixels (from first selection made on ref channel)
		image_first_selection = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities" + File.separator +
								imagenames[0] + "_2D_profile_channel" + ref_channel + "_1.txt");
		rows = split(image_first_selection, "\n");
		single_line = split(rows[0], "\t");
		height = single_line.length;
	
		for(chann = 1; chann < types.length + 1; chann ++){
		
	// extract pixel values from single pattern and add them in one array
			flattened_image = newArray(median_pattern_size_in_pixels*height); // defines new image
			
			for (k = 0; k < imagenames.length; k++) {
					l = 1;
					while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities" + File.separator +
										imagenames[k] + "_2D_profile_channel" + ref_channel + "_" + l +".txt")==1)
						{
						// opens the image selection in the appropriate channel	
						image_selection = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities" + 
																File.separator + imagenames[k] + "_2D_profile_channel" + chann + "_" + l +".txt");
						image_selection_rows = split(image_selection, "\n"); // the image selection was saved in a previous step with the selection being vertical
						image_selection_rows_0 = split(image_selection_rows[0], "\t");
						if(lengthOf(image_selection_rows_0)==height){// checks pattern has the right height (same linewidth as first selection), if yes continues
							
							// stores the image selection in an array to use at a later step
							image_selection_length = lengthOf(image_selection_rows);
							image_selection_flattened = newArray(height*image_selection_length);
							for (i = 0; i < image_selection_length; i++){
								single_row_i = split(image_selection_rows[i], "\t");
								for (j = 0; j < height; j++){
									image_selection_flattened[i * height + j] = parseFloat(single_row_i[j]);
								}
							}
							
							// uses the ref channel to know how to align patterns in multiple-color datasets 
						
							localizations = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator  + "internal" + File.separator +
																imagenames[k] + "_localizations_channel_" +	ref_channel + "_" + l +".txt");
							localizations_rows = split(localizations, "\n");
							
								// the reference of a given pattern, ie its center, may be defined differently based on the type of pattern
								// - if the reference channel consists of multiple bands in one pattern, the average position of bands is used as its "center"
								// - for actin-like patterns, the center peak is used
								// - for block patterns, the middle position of edges is used
								// NB: in types "i" for band, "a" for actin, "b" for block, "o" for other, "q" for quantile algorithm for actin
								
							center_of_pattern = newArray(localizations_rows.length); // to save the center position of each pattern
							
							if (types[ref_channel-1] == "i" || types[ref_channel-1] == "v" || types[ref_channel-1] =="b") {
								for (i = 0; i < localizations_rows.length; i++) {
									within_row_loc = split(localizations_rows[i], "\t"); // extracts localizations saved in one row (corresponds to one pattern)
									locs = newArray(within_row_loc.length);
									for (p = 0; p < within_row_loc.length; p++) {locs[p] = parseFloat(within_row_loc[p]);}

									Array.getStatistics(locs, min, max, mean, stdDev);
									center_of_pattern[i] = mean;}} //takes the average position of all features as the reference
							
							else if (types[ref_channel-1] == "a" || types[ref_channel-1] == "q") {
								for (i = 0; i < localizations_rows.length; i++) {
								within_row_loc = split(localizations_rows[i], "\t");
								center_of_pattern[i] = parseFloat(within_row_loc[1]);}}  //use the center peak position as the reference

							else {Dialog.create("There is a problem...");
								Dialog.addMessage("Your reference channel is not a type supported \nPlease try another channel or consider changing parameters");
								Dialog.show;
								break;}
							
							for (i = 0; i < localizations_rows.length; i++) {
								// checks if pattern is complete
								if((((center_of_pattern[i])/pixelsize - median_pattern_size_in_pixels/2 -1)>0) && 
											((center_of_pattern[i]/pixelsize + median_pattern_size_in_pixels/2 +1) < image_selection_length)){
									x = center_of_pattern[i]/pixelsize; // position of center of pattern on the image selection in (sub)pixel
									n = Math.floor(x); // floored version of center of pattern
									epsilon = x - n; // and the remaining of the center (between 0 and 1)
									for(j = 0; j < median_pattern_size_in_pixels; j ++){
										for(m = 0; m < height; m ++){
											pixel_before = image_selection_flattened[Math.ceil(n + j - median_pattern_size_in_pixels / 2) * height + m];
											pixel_after = image_selection_flattened[Math.ceil(n + 1 + j - median_pattern_size_in_pixels / 2) * height + m];
	
											flattened_image[j * height + m] = flattened_image[j * height + m] + (1 - epsilon) * pixel_before + epsilon * pixel_after;
										}
									}
								}
							}
							
						}
						l = l + 1;}
					}
		
				if(chann == 1){
					avg_pattern_window_name = Name_window_iteratively("Average pattern");
					newImage(avg_pattern_window_name, "32-bit composite-mode", median_pattern_size_in_pixels, height, types.length, 1, 1);
					profile = newArray(median_pattern_size_in_pixels * types.length);
							for(i = 0; i < median_pattern_size_in_pixels; i ++){
								profile_at_i = 0;
								for(j = 0; j < height; j ++){
									profile_at_i = profile_at_i + flattened_image[i * height + j];}// generates error
								profile[i] = profile_at_i;}
								}
				Stack.setChannel(chann);
				for(i = 0; i < median_pattern_size_in_pixels; i ++){
					for(j = 0; j < height; j ++){
						setPixel(i, j, flattened_image[i * height + j]);
					}}
					run("Enhance Contrast", "saturated=0.35");
					for(i = 0; i < median_pattern_size_in_pixels; i ++){
								profile_at_i = 0;
								for(j = 0; j < height; j ++){
									profile_at_i = profile_at_i + flattened_image[i * height + j];
								}
								profile[i+(chann-1)*median_pattern_size_in_pixels] = profile_at_i;}}
		
		if (types.length > 1) {
													
			image_colors = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator  + "colors.txt");
			image_rows = split(image_colors, "\n");
			for (c = 1; c < types.length + 1; c++) {
				Stack.setChannel(c);
				col = 0;
				for (line = (c-1)*3; line < (c-1)*3+3; line++) {
									
					LUT = split(image_rows[line], ",");
					LUT_num = newArray(LUT.length);
					for(i = 0; i < LUT.length; i++){
						LUT_num[i] = parseInt(LUT[i]);
					}
					if (col == 0) {reds = LUT_num;}
					else if(col == 1) {greens = LUT_num;}
					else {blues = LUT_num;}
					col = col + 1;}

				setLut(reds, greens, blues);
			}}	
					
		run("In [+]");
		run("In [+]");
		run("In [+]");
					
					
	// Display a profile of the averaged pattern				
	
		xValues = Array.getSequence(median_pattern_size_in_pixels); // sets the values in pixels for x axis
		for (i = 0; i < xValues.length; i++) {
				xValues[i] =  xValues[i]*pixelsize;
			}
		// sets graph colors
		Stack.getDimensions(width, height, channels, slices, frames);
	// sets graph colors 
	    Plotcolors = newArray(channels);
	
	    if (channels > 1) {
	        for(c=1; c<channels+1; c++){
	            
	            Stack.setChannel(c);
	        
	            getLut(reds, greens, blues);
	            
	            R = toHex(reds[reds.length-1]);
	            G = toHex(greens[greens.length-1]);
	            B = toHex(blues[blues.length-1]);
	
	        	// makes sure there is no white graph, and gives darker colors for most used colors
	            if(R=="ff" && G=="ff" && B == "ff"){R="00"; G="00"; B="00";}
	            if(R=="0" && G=="ff" && B == "0"){R="00"; G="aa"; B="00";}
	            if(R=="ff" && G=="0" && B == "0"){R="dd"; G="00"; B="00";}
	            if(R=="0" && G=="0" && B == "ff"){R="00"; G="00"; B="cc";}
	            if(R=="ff" && G=="0" && B == "ff"){R="dd"; G="00"; B="cc";}
	            if(R=="0"){R="00";}
	            if(G=="0"){G="00";}
	            if(B=="0"){B="00";}
	        
	            Plotcolors[c-1] = "#" + R + G + B;
	            }}
	     else {
	     		Plotcolors[0] = "#000000";}
	        
		// creates the graph with profiles
			profile_window_name = Name_window_iteratively("Average pattern profile");
	        Plot.create(profile_window_name, "Position", "Normalized intensity");
	
	                if(types.length >1){
	                    Plot.setColor("black");
	                    Plot.addText("channels", 0, 0);}
	                    
	                for (i=0; i<types.length; i++){
	                    subprofile = Array.slice(profile,median_pattern_size_in_pixels*i,median_pattern_size_in_pixels*(i+1));
	                    Array.getStatistics(subprofile, min, max, mean, stdDev);
	                    for (k = 0; k < subprofile.length; k++) {
	                        subprofile[k] = (subprofile[k]-min)/(max-min)+types.length-i-1;
	                        }
	                    Plot.setColor(Plotcolors[i]);
	                    Plot.add( "line", xValues, subprofile);
	                    display_channel = toString(i+1);
	                    if(types.length >1){Plot.addText(display_channel, 0.15 + i/25, 0);//add the number of channel with its color on top of the graph
	                    }}
	                    
	        Plot.setLimits(0, median_pattern_size_in_pixels*pixelsize, -0.1, types.length+0.1); 
	        Plot.show();	
}




/////**************************************************************************/////

function Name_window_iteratively(basic_name){
	
/// Checks images and graphs names already in use and iterate on them

	k = 0;
	list = getList("image.titles");
	  if (list.length == 0){
	     name = basic_name;}
	  else{
	     for (i=0; i<list.length; i++)
	        if(list[i] == basic_name){
	        	k = 1;}
	      name = basic_name;}
	      
	 if(k == 1){
	 	list_of_windows_with_basicname = newArray("");
	 	for (i=0; i<list.length; i++){
		 	if(list[i].length >= basic_name.length + 1){
		 		totest = basic_name + "_";
		 		substr = substring(list[i], 0, basic_name.length + 1 );
		        if(substr == totest){
		        	list_of_windows_with_basicname = Array.concat(list_of_windows_with_basicname, substring(list[i], basic_name.length + 1 ));
		        	k = 2;}}}
	    name = basic_name + "_1" ;}
	    
	 if(k == 2){
		list_of_window_number = newArray(0);
	 	for (i=1; i<list_of_windows_with_basicname.length; i++){
	 		list_of_window_number = Array.concat(list_of_window_number, parseFloat(list_of_windows_with_basicname[i]));
	 		}
	 	list_of_window_number = Array.sort(list_of_window_number);
	 	name = basic_name + "_" + toString(list_of_window_number[list_of_window_number.length-1]+1);
	 	}
	 return name;
	}	



/////**************************************************************************/////
/////**************************************************************************/////
/////**************************************************************************/////
/////**********************                              **********************/////
/////**********************    Timeplapse functions      **********************/////
/////**********************                              **********************/////
/////**************************************************************************/////
/////**************************************************************************/////
/////**************************************************************************/////
/////**************************************************************************/////


function Introduction_timelapse(){
	
	// Check if there is an image opened
	
	list = getList("image.titles");
	if (list.length == 0){
	  	Dialog.create("There is a problem...");
		Dialog.addMessage("No image can be found.\nOpen an image to analyze and try again.");
		Dialog.show;
		exit;}
	
	
	// check whether there are more than one slice or frame in the image
	
	getDimensions(width, height, channels, slices, frames);
	
	if(slices<2 && frames<2){
		Dialog.create("There is a problem...");
		Dialog.addMessage("It seems your image has only one frame or slice.");
		Dialog.addMessage("Try again with an image sequence.");
		Dialog.show;
		exit;}
	
	else {
		
		if(roiManager("size") > 0){
						// ask the user if the ROI manager can be emptied
						showMessageWithCancel("The ROI manager is not empty...", "It seems like your ROI manager is not empty.\n"+
						"Is it ok for you if I delete the current selection(s) from the ROI manager?\n \n" +
						"If you used PatternJ on a previous image, selections are already saved.\nI just make some space for your timelapse selections: simply press \"OK\".\n \n" +
						"If these selections are not from PatternJ, but you want to keep them\nand did not save them yet, press \"Cancel\"");
						
						roiManager("reset");//deletes all current selections if users clicks "OK"
						}
		
		Dialog.createNonBlocking("Draw a few reference selections");
					Dialog.addMessage("Draw a few reference selections on your time lapse", 15, "#0000ff");
					
					Dialog.addMessage("You need to draw a few reference selections (at least two) between the first and last frame of interest.\n"+
									  "From this I will generate the selections in between with interpolation.");
									  
					Dialog.addMessage("Step 1", 12, "#0000ff");			  
					Dialog.addMessage("Draw a selection on your image.\n \nDon't hesitate to increase the linewidth for best results.");
					Dialog.addMessage("Previous ROIs can also be imported.\nSelect the ROI manager window, select \"More >>\" and click \"Open\".");
					Dialog.addMessage("Step 2", 12, "#0000ff");	
					Dialog.addMessage("Press \"T\" on your keyboard to add the selection to the ROI manager.\n "+
										"The ROI manager may be below your image.\n");
									  
					Dialog.addMessage("Repeat Step 1 and Step 2 to add as many selections as you wish (max. one per image)", 12, "#0000ff");	
					
					Dialog.addMessage("Once you are happy with your few selections press \"OK\"", 12, "#00cc44");
					
					Dialog.addChoice("The analysis will be on", newArray("frames (time)", "slices (z)"));
					
					Dialog.addMessage("NB: your selections will be saved in the Analyses\\Timelapse folder.\n"+
										"They can be reloaded if needed.\n");
					
					if(channels > 1){
						choose_channel_array = newArray(channels);
						for (i = 0; i < channels; i++) {
							choose_channel_array[i] = toString(i+1);
							}

						Dialog.addChoice("Channel to be used as reference:", choose_channel_array);}
						
					Dialog.addMessage("Your image will disappear during the analysis.\n You can see the progress in the status bar.", 12, "#ff0000");
					
					Dialog.show;
					
					frame_or_slice = Dialog.getChoice();
					
					if(channels > 1){
					chosen_channel = Dialog.getChoice();
					}
					else{chosen_channel = "1";}
					
					return frame_or_slice + "_" + chosen_channel;
		}}
		
		
/////**************************************************************************/////


function Save_selection_ROI_for_timelapse(){
	
	/// Saves the ROIs selected by the user for a timelapse
	image_folder = Read_image_folder_name();
	
	timelapse_folder = image_folder + File.separator + "Analyses" + File.separator + "Timelapse";
	
	if (File.exists(timelapse_folder)!=1) {
		File.makeDirectory(timelapse_folder);}
	//Check how many ROIsets have already been used on the image to pick the right name
	i = 1;
	j = 1;
	  while (File.exists(timelapse_folder + File.separator + "ROI_set" + i +".zip")==1)
		{    
	     i = i + 1;
	     j = i;  } //keep j as the increment to use
	
	roiManager("save", timelapse_folder + File.separator + "ROI_set" + j +".zip");
	
	return j;
}

/////**************************************************************************/////
				
function ROI_morpher(frame_or_slice, file_number){
	
	showStatus("Morphing your selections");
	
	Stack.getDimensions(width, height, channels, slices, frames);

	ROI_count = roiManager("count");
	
	// Check if there are at least 2 selections
	if (ROI_count<2) {
		Dialog.create("There is a problem...");
		Dialog.addMessage("It seems too little selections were made.");
		Dialog.addMessage("Repeat by pressing \"T\" on your keyboard to save your selections one by one.");
		Dialog.show;
		exit;}
	
	// at least two selections were found
	else {
				
		if(frames == 1){ frame_or_slice = "slices (z)";} // switch to slices if frames were selected but only one frame is found
		
		if (frame_or_slice == "frames (time)") {
			//Analysis temporal
			
			//Check if there are at least two frames in the sequence
				if (frames < 2) {
						Dialog.create("There is a problem...");
						Dialog.addMessage("It seems your image has only one time point.");
						Dialog.addMessage("Were you interested in analyzing slices rather?\n \n"+
											"It is possible that Fiji mistaken your frames for slices\n"+
											"Try again and select \"slices (z)\"");
						Dialog.show;
						exit;}
					
			//Check if selections were made on at least two different frames in the sequence
				frames_array = newArray(ROI_count); // to save in which frame a selection was made
				
				for (i = 0; i < ROI_count; i++) {
					RoiManager.select(i);
					Stack.getPosition(channel, slice, frame);
					frames_array[i] = frame;
					}
				sorted_frames_array = Array.copy(frames_array);
				Array.sort(sorted_frames_array);
				min_frame = sorted_frames_array[0];
				max_frame = sorted_frames_array[ROI_count - 1];
				
				if(max_frame-min_frame == 0){
					Dialog.create("There is a problem...");
						Dialog.addMessage("It seems your selections are on the same time point.");
						Dialog.addMessage("Were you interested in analyzing slices rather?\n \n"+
											"It is possible that Fiji mistaken your frames for slices\n"+
											"Try again and select \"slices (z)\"");
						Dialog.show;
						exit;}
					
			//Obtain the order of selections in case they were not drawn in a correct order from earliest time point to latest
				array_index = Array.getSequence(ROI_count); // returns 1,2,...,n
				Array.sort(frames_array, array_index);
			
			//Generate selections from min to max frames
				RoiManager.select(0);
				name_selection_1 = RoiManager.getName(0);//uses the name of the first selection as a template for the next selections
				linewidth = getValue("selection.width");
				
				getPixelSize(unit, pw, ph, pd);
				
				image_folder = Read_image_folder_name();
				timelapse_folder = image_folder + File.separator + "Analyses" + File.separator + "Timelapse";
				
				path_user_selected_ROIs = timelapse_folder + File.separator + "ROI_set" + file_number +".zip";
				path_interpolated_ROIs = timelapse_folder + File.separator + "ROI_set_interpolated" + file_number +".zip";
				
				for (i = 0; i < ROI_count-1; i++) {
					
					if(i > 0){
						// In the first loop the ROI manager is already opened with user selected ROIs, but it is closed later on.
						// Therefore, opens the user selected ROIs in next loop iterations
						roiManager("open", path_user_selected_ROIs);
						}
						
					//get the coordinates of two selections next to one another in time
					
					RoiManager.select(array_index[i]); // select the ROI in the order of appearance on frames
					run("Interpolate", "interval=1 adjust");
					getSelectionCoordinates(xpoints_pre, ypoints_pre);
					
					RoiManager.select(array_index[i+1]);
					run("Interpolate", "interval=1 adjust");
					getSelectionCoordinates(xpoints_post, ypoints_post);
					
					//roiManager("reset");//raise java errors
					// delete selections to make space for interpolated ones
					roiManager("delete"); if(roiManager("count") > 0){roiManager("delete");}
						
						
					//interpolate ROIs and save them
					xpoints_pre_resampled = Array.resample(xpoints_pre, 100);
					ypoints_pre_resampled = Array.resample(ypoints_pre, 100);
					xpoints_post_resampled = Array.resample(xpoints_post, 100);
					ypoints_post_resampled = Array.resample(ypoints_post, 100);
					
					if(i > 0){	// open the interpolated ROIs from the 2nd loop iteration, to add new interpolated lines
						roiManager("open", path_interpolated_ROIs);
						}
					
					run("Line Width...", "line=" + linewidth);
					beginning = sorted_frames_array[i];
					end = sorted_frames_array[i+1];
					delay_between_selections = end - beginning;
					//initialize the selection to be made
					x = newArray(100);
					y = newArray(100);
					for(t = beginning; t < end; t++){ 
						for(j = 0; j < 100; j++){
							x[j] = xpoints_pre_resampled[j]*(1 - (t-beginning)/delay_between_selections) + xpoints_post_resampled[j]*(t-beginning)/delay_between_selections;
							y[j] = ypoints_pre_resampled[j]*(1 - (t-beginning)/delay_between_selections) + ypoints_post_resampled[j]*(t-beginning)/delay_between_selections;
							}
						Stack.setFrame(t);	
						makeSelection("polyline", x, y);
						roiManager("add");
						name = "interp_time_" + toString(t) + "_" + name_selection_1;
						roiManager("select", roiManager("size")-1);
						roiManager("rename", name);
						Stack.getPosition(channel, slice, frame);
						Roi.setPosition(channel, slice, frame);
						roiManager("save", path_interpolated_ROIs);
						}
						
					//roiManager("reset");//raise java errors
					// Deletes selections to make space for next cycle of for loop
					roiManager("delete"); if(roiManager("count") > 0){roiManager("delete");}
					}
					//adds the last selection to the list of ROIs
					roiManager("open", path_user_selected_ROIs);
					RoiManager.select(ROI_count - 1);
					//roiManager("reset");//raise java errors
					roiManager("delete"); if(roiManager("count") > 0){roiManager("delete");}
					
					roiManager("open", path_interpolated_ROIs);
					roiManager("add");
					name = "interp_time_" + toString(end) + "_" + name_selection_1;
					roiManager("select", roiManager("size")-1);
					roiManager("rename", name);
					Stack.getPosition(channel, slice, frame);
					Roi.setPosition(channel, slice, frame);
					roiManager("save", path_interpolated_ROIs);
			
			}

		else{
			//Analysis spatial
				//Check if there are at least two slices in the sequence
				if (slices < 2) { //// here diff with frame
						Dialog.create("There is a problem...");
						Dialog.addMessage("It seems your image has only one slice.");//// here diff with frame
						Dialog.addMessage("Were you interested in analyzing timepoints rather?\n \n"+//// here diff with frame
											"It is possible that Fiji mistaken your frames for slices\n"+
											"Try again and select \"frames (time)\"");//// here diff with frame
						Dialog.show;
						exit;}
					
			//Check if selections were made on at least two different slices in the sequence
				frames_array = newArray(ROI_count);
				for (i = 0; i < ROI_count; i++) {
					RoiManager.select(i);
					Stack.getPosition(channel, slice, frame);
					frames_array[i] = slice;//// here diff with frame
					}

				sorted_frames_array = Array.copy(frames_array);
				Array.sort(sorted_frames_array);
				min_frame = sorted_frames_array[0];
				max_frame = sorted_frames_array[ROI_count - 1];
				
				if(max_frame-min_frame == 0){
					Dialog.create("There is a problem...");
						Dialog.addMessage("It seems your selections are on the same slice.");//// here diff with frame
						Dialog.addMessage("Were you interested in analyzing timepoints rather?\n \n"+//// here diff with frame
											"It is possible that Fiji mistaken your frames for slices\n"+
											"Try again and select \"frames (time)\"");//// here diff with frame
						Dialog.show;
						exit;}
					
			//Obtain the order of selections in case they were not drawn in a correct order from earliest time point to latest
				array_index = Array.getSequence(ROI_count);
				Array.sort(frames_array, array_index);
				
			//Generate selections from min to max frames
				RoiManager.select(0);
				name_selection_1 = RoiManager.getName(0);
				linewidth = getValue("selection.width");
				
				getPixelSize(unit, pw, ph, pd);
				
				image_folder = Read_image_folder_name();
				timelapse_folder = image_folder + File.separator + "Analyses" + File.separator + "Timelapse";
				
				path_user_selected_ROIs = timelapse_folder + File.separator + "ROI_set" + file_number +".zip";
				path_interpolated_ROIs = timelapse_folder + File.separator + "ROI_set_interpolated" + file_number +".zip";
				
				for (i = 0; i < ROI_count-1; i++) {
					
					if(i > 0){
					// In the first loop the ROI manager is already opened with user selected ROIs, but it is closed later on.
					// Therefore, opens the user selected ROIs in next loop iterations
						roiManager("open", path_user_selected_ROIs);
						}
						
					//get the coordinates of two selections next to one another in slices
					
					RoiManager.select(array_index[i]);
					run("Interpolate", "interval=1 adjust");
					getSelectionCoordinates(xpoints_pre, ypoints_pre);
					
					RoiManager.select(array_index[i+1]);
					run("Interpolate", "interval=1 adjust");
					getSelectionCoordinates(xpoints_post, ypoints_post);
					
					//roiManager("reset");//raise java errors
					// delete selections to make space for interpolated ones
					roiManager("delete"); if(roiManager("count") > 0){roiManager("delete");}
						
						
					//interpolate ROIs and save them
					xpoints_pre_resampled = Array.resample(xpoints_pre, 100);
					ypoints_pre_resampled = Array.resample(ypoints_pre, 100);
					xpoints_post_resampled = Array.resample(xpoints_post, 100);
					ypoints_post_resampled = Array.resample(ypoints_post, 100);
					
					if(i > 0){	// open the interpolated ROIs from the 2nd loop iteration, to add new interpolated lines
						roiManager("open", path_interpolated_ROIs);
						}
					
					run("Line Width...", "line=" + linewidth);
					beginning = sorted_frames_array[i];
					end = sorted_frames_array[i+1];
					delay_between_selections = end - beginning;
					//initialize the selection to be made
					x = newArray(100);
					y = newArray(100);
					for(t = beginning; t < end; t++){ 
						for(j = 0; j < 100; j++){
							x[j] = xpoints_pre_resampled[j]*(1 - (t-beginning)/delay_between_selections) + xpoints_post_resampled[j]*(t-beginning)/delay_between_selections;
							y[j] = ypoints_pre_resampled[j]*(1 - (t-beginning)/delay_between_selections) + ypoints_post_resampled[j]*(t-beginning)/delay_between_selections;
							}
						Stack.setPosition(channel, t, frame);	//// here diff with frame
						makeSelection("polyline", x, y);
						roiManager("add");
						name = "interp_time_" + toString(t) + "_" + name_selection_1;
						roiManager("select", roiManager("size")-1);
						roiManager("rename", name);
						Roi.setPosition(channel, t, frame);
						roiManager("save", path_interpolated_ROIs);
						}
						
					roiManager("delete"); if(roiManager("count") > 0){roiManager("delete");}
					//roiManager("reset"); //raise java errors
					}
					//adds the last selection to the list of ROIs
					roiManager("open", path_user_selected_ROIs);
					RoiManager.select(ROI_count - 1);
					//roiManager("reset"); //raise java errors
					roiManager("delete"); if(roiManager("count") > 0){roiManager("delete");}
					
					roiManager("open", path_interpolated_ROIs);
					roiManager("add");
					name = "interp_time_" + toString(end) + "_" + name_selection_1;
					roiManager("select", roiManager("size")-1);
					roiManager("rename", name);
					Stack.getPosition(channel, slice, frame);
					Roi.setPosition(channel, slice, frame);
					roiManager("save", path_interpolated_ROIs);
			}}
	
	return frame_or_slice + "_" + toString(min_frame);
}

/////**************************************************************************/////

function Extract_and_save_timelapse(image_folder_name, imagenumber, timelapseID){
	
	ROI_count = roiManager("count");
	
	Plot.create("Profile checker timelapse / depth: "+imagenumber, "Pixel position", "Normalized intensity");
	
	//*** Read the metadata file to know what to analyse ***//
		types = ReadInfo_type(image_folder_name); //array of char with type of channel
		nb_bands = ReadInfo_bands(image_folder_name); //array of int with number of channels
		channel_Z_or_M = ReadInfo_channel_ZM(image_folder_name); //array of char ("Z" or "M") with info on data centered on Z-disk or M-line
		drawn_Z_or_M = ReadInfo_drawnZM(image_folder_name); //returns 0 if from (edge to edge)/(Z-disk to Z-disk), 1 if from (center to center)/(M-line-to-M-line)
		
	//*** Extra info on stack ***//
		Stack.getDimensions(width, height, channels, slices, frames);
		getPixelSize(unit, pixelWidth, pixelHeight);
		
		Plotcolors_profile = Profile_colors_timelapse(imagenumber, channels);
		Plotcolors_adder = Plot_adder_colors_timelapse(imagenumber, channels);
	//*** Extract & save positions ***//
	
	for (i = 0; i < ROI_count; i++) {
		showStatus("PatternJ: analysis is " + round(i/ROI_count*100) + "% complete");
		
		RoiManager.select(i);
		
		for (j=1; j<channels + 1; j++){
			if (channels > 1) {
				Stack.setChannel(j);}
			
			profile = getProfile(); 
			
			avgSizeSarcomere = autoCorr(profile);//given in pixels
			posPattern = crossCorr(profile, avgSizeSarcomere, channel_Z_or_M[j-1], drawn_Z_or_M);
						//image_folder_name, channel, profile, type, nb_band, avgSizeSarcomere, posPattern, channel_ZM, temp, timelapseID) 
						//temp = 1 will save data in "temp" files, not used in analysis 
			Localization(image_folder_name, j, profile, types[j-1], nb_bands[j-1], avgSizeSarcomere, posPattern, channel_Z_or_M[j-1],2,timelapseID, 0); 
			//2 at the end stands for saving files with extracted positions
			Profile_lengths(image_folder_name, profile.length);
			}
	
		//*** Save intensity in ROI ***//
		//SaveROI_timelapse();
	
		//*** Display positions in a graph ***//
		RoiManager.select(i);
		Profile_checker_timelapse(imagenumber, Plotcolors_profile);
		Position_in_plot_adder_timelapse(image_folder_name,imagenumber,types, pixelWidth, timelapseID, i+1, Plotcolors_adder);
		}
		
		Plot.show;
		return timelapseID;
}


/////**************************************************************************/////

function Profile_lengths(image_folder_name, profile_length) {
	
	profile_length_file_path = image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse" + File.separator + "internal" + File.separator + "profile_lengths.txt";
	
	File.append(toString(profile_length), profile_length_file_path);}

/////**************************************************************************/////

function Profile_colors_timelapse(imagenumber, channels) {
	
	selectWindow(imagenumber);  
	Plotcolors = newArray(channels);
	
    if (channels > 1) {
        for(c=1; c<channels+1; c++){
            
            Stack.setChannel(c);
        
            getLut(reds, greens, blues);
            
            R = toHex(reds[reds.length-1]);
            G = toHex(greens[greens.length-1]);
            B = toHex(blues[blues.length-1]);

        	// makes sure there is no white graph, and gives darker colors for most used colors
            if(R=="ff" && G=="ff" && B == "ff"){R="00"; G="00"; B="00";}
            if(R=="0" && G=="ff" && B == "0"){R="00"; G="aa"; B="00";}
            if(R=="ff" && G=="0" && B == "0"){R="dd"; G="00"; B="00";}
            if(R=="0" && G=="0" && B == "ff"){R="00"; G="00"; B="cc";}
            if(R=="ff" && G=="0" && B == "ff"){R="dd"; G="00"; B="cc";}
            if(R=="0"){R="00";}
            if(G=="0"){G="00";}
            if(B=="0"){B="00";}
        
            Plotcolors[c-1] = "#" + R + G + B;
            }}
     else {
     		Plotcolors[0] = "#000000";}
     		
     return Plotcolors;
	     }


/////**************************************************************************/////

function Profile_checker_timelapse(imagenumber, Plotcolors) {


    // Extracts profiles
    
	    selectWindow(imagenumber);    
		
	    profile = getProfile();//check if a selection is there
	
		xValues = Array.getSequence(profile.length); // sets the values in pixels for x axis
	    Stack.getDimensions(width, height, channels, slices, frames);
	    Stack.getPosition(current_channel, slice, frame);// used to come back to inital channel at the end of macro

		    // saves all profiles in one array
		    all_profiles = newArray();
		    for (i=1; i<channels + 1; i++){
		        if(channels >1){
		        	Stack.setChannel(i);}
		        profile = getProfile();
		        all_profiles = Array.concat(all_profiles,profile);}        

                if(channels >1){
                    Stack.setChannel(current_channel);
                    Plot.setColor("black");
                    Plot.addText("channels", 0, 0);}
                    
                for (i=0; i<channels; i++){
                    subprofile = Array.slice(all_profiles,profile.length*i,profile.length*(i+1));
                    Array.getStatistics(subprofile, min, max, mean, stdDev);
                    for (k = 0; k < subprofile.length; k++) {
                        subprofile[k] = (subprofile[k]-min)/(max-min)+channels-1-i;
                        }
                    Plot.setColor(Plotcolors[i]);
                    Plot.add( "line", xValues, subprofile); // display plot
                    display_channel = toString(i+1);
                    if(channels >1){Plot.addText(display_channel, 0.15 + i/25, 0);//add the number of channel with its color on top of the graph
                    }}
                    
        Plot.setLimits(0, profile.length, -0.1, channels+0.1);
        
}

/////**************************************************************************/////

function Plot_adder_colors_timelapse(imagenumber, channels) {
	    Plotcolors = newArray(channels);
		Imagecolors = "";
		
	    if (channels > 1) {
	        for(c=1; c<channels+1; c++){
	            
	            Stack.setChannel(c);
	        
	            getLut(reds, greens, blues);
	            
	            Imagecolors = Imagecolors + String.join(reds) + "\n" + String.join(greens) + "\n"+ String.join(blues) + "\n";
	            
	            R = toHex(reds[reds.length-1]);
	            G = toHex(greens[greens.length-1]);
	            B = toHex(blues[blues.length-1]);
	
	        	// makes sure there is no white graph, and gives darker colors for most used colors
	            if(R=="ff" && G=="ff" && B == "ff"){R="03"; G="03"; B="03";}
	            if(R=="0" && G=="ff" && B == "0"){R="00"; G="88"; B="00";}
	            if(R=="ff" && G=="0" && B == "0"){R="aa"; G="00"; B="00";}
	            if(R=="0" && G=="0" && B == "ff"){R="00"; G="00"; B="99";}
	            if(R=="ff" && G=="0" && B == "ff"){R="aa"; G="00"; B="99";}
	            if(R=="0"){R="00";}
	            if(G=="0"){G="00";}
	            if(B=="0"){B="00";}
	        
	            Plotcolors[c-1] = "#" + R + G + B;
	            }
	        }
	     else {
	     		Plotcolors[0] = "#aa0000";}
	     return Plotcolors;}

/////**************************************************************************/////

function Position_in_plot_adder_timelapse(image_folder_name,imagenumber,types, pixelWidth, timelapseID, time, Plotcolors) {//temp = 1 will use "temp" files

	///*** Plot the positions extracted in profiles in the profile graph ***///
	
	Stack.getDimensions(width, height, channels, slices, frames);
	
	// plot positions found
	
	for (i = 0; i < types.length; i++) {
			Plot.setColor(Plotcolors[i]);

			chann = i + 1;

			localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal" + File.separator +
													imagenumber + "_localizations_channel_" + chann + "_timelapse_" + timelapseID + "_t_" + time +".txt");
				
			rows=split(localization_file, "\n");
			
			if (rows.length == 0) {//finds an empty result
				Dialog.create("There is a problem...");
				Dialog.addMessage("Sorry, I cannot fit your data.");
				Dialog.addMessage("Consider trying another selection or one of the other fitting methods.");
				Dialog.show;
				exit;
			}
			
			else {
				for(m=0; m<rows.length; m++){
					elements=split(rows[m],"\t");
					if ((types[i] == "i") | (types[i] == "q") | (types[i] == "v")| (types[i] == "s")) {//type individual bands or type actin quantile algorithm
						end = elements.length;}
	
					else if (types[i] == "a") {//type actin
						end = 3;}
	
					else if (types[i] == "b") {//type individual block
						end = elements.length/2;}
						
						for (l = 0; l < end; l++) {
							x1 = 1/pixelWidth*elements[l];
							xValues = newArray(x1,x1);
							yValues = newArray(channels-1-i,channels-i);
							Plot.add( "line", xValues, yValues);}
							}
						}
			}
			Plot.appendToStack;
			}

/////**************************************************************************/////


function SaveROI_timelapse(){		/// Needs to add time in the filename to be useful
//Save the 2D intensity information of the ROI
	
	if (File.exists(image_folder_name + File.separator + "Analyses"+ File.separator + "Timelapse"+ File.separator + "ROI_intensities")!=1) {
			File.makeDirectory(image_folder_name + File.separator + "Analyses"+ File.separator + "Timelapse"+ File.separator + "ROI_intensities");}
			
	ROI_directory_timelapse = image_folder_name + File.separator + "Analyses"+ File.separator + "Timelapse"+ File.separator + "ROI_intensities";
	
	imagenumber = getTitle();// get the title of the image
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(current_channel, slice, frame);			
	
	//Check how many ROI have already been used on the image to pick the right name
	i = 1;
	j = 1;
	  while (File.exists(ROI_directory_timelapse + File.separator + imagenumber + "_2D_profile_channel1_" + i +".txt")==1)
	{    
	     i = i + 1;
	      j = i;  } //keep j as the increment to use
	
	run("Interpolate", "interval=1 smooth");    //interpolate the ROI with 1 pixel
	Roi.getCoordinates(x,y);    //get the positions of each point
	
	////// Local segments perpendicular to the junction are used to obtain the profile perpendicular to the segment drawn by the user, every pixel along the segment
	
	getLine(x1, y1, x2, y2, lineWidth); //get the linewidth used
	
	for (i=1; i<channels + 1; i++)
	{    if (channels > 1) {Stack.setChannel(i);}
	
	// create file for profile on channel i
	File.saveString("", ROI_directory_timelapse + File.separator + imagenumber + "_2D_profile_channel" + i + "_" + j +".txt")
	
	    f = File.open(ROI_directory_timelapse + File.separator + imagenumber + "_2D_profile_channel" + i + "_" + j +".txt");
	
	// create unitary segments to define profiles perpendicular to the segment drawn
	   for (k=0; k<lengthOf(x)-2; k++)
	    {        if (k<3) {
	            norm = sqrt((x[0]-x[6])*(x[0]-x[6])+(y[0]-y[6])*(y[0]-y[6]));
	            unit_perp_x = (-(y[6]-y[0])/norm);
	            unit_perp_y = ((x[6]-x[0])/norm);
	            }
	            else if (k>lengthOf(x)-4) {
	            norm = sqrt((x[lengthOf(x)-7]-x[lengthOf(x)-1])*(x[lengthOf(x)-7]-x[lengthOf(x)-1])+(y[lengthOf(x)-7]-y[lengthOf(x)-1])*(y[lengthOf(x)-7]-y[lengthOf(x)-1]));
	            unit_perp_x = (-(y[lengthOf(x)-1]-y[lengthOf(x)-7])/norm);
	            unit_perp_y = ((x[lengthOf(x)-1]-x[lengthOf(x)-7])/norm);
	            }
	            else {
	            norm = sqrt((x[k-3]-x[k+3])*(x[k-3]-x[k+3])+(y[k-3]-y[k+3])*(y[k-3]-y[k+3]));
	            unit_perp_x = (-(y[k+3]-y[k-3])/norm);
	            unit_perp_y = ((x[k+3]-x[k-3])/norm);
	            }
	                        
	        // From the reference line, creates a segment (profile line) whose middle is a given point of the reference line,
	        // its length is the linewidth and  it is locally perpendicular to the reference line
	        if(lineWidth == 0){lineWidth = 1;}
	        lengthofprofile = lineWidth;
	        profile=newArray(lengthofprofile);
	
	        for (l=0; l<lengthOf(profile); l++)
	        {    //interpolation of the value of pixel along the profile line
	            xM = x[k] + (l-(lengthOf(profile)-1)/2)*unit_perp_x;
	            yM = y[k] + (l-(lengthOf(profile)-1)/2)*unit_perp_y;
	
	            espilon_x = (xM-floor(xM));
	            espilon_y = (yM-floor(yM));
	                        
	            profile[l] = (1-espilon_x)*(1-espilon_y)*getPixel(floor(xM),floor(yM))
	                        +(espilon_x)*(1-espilon_y)*getPixel(floor(xM)+1,floor(yM))
	                        +(espilon_x)*(espilon_y)*getPixel(floor(xM)+1,floor(yM)+1)
	                        +(1-espilon_x)*(espilon_y)*getPixel(floor(xM),floor(yM)+1);
	        }
	
	        string="";
	        for (l=0; l<lengthOf(profile); l++) {
	            if (l==0) {
	                string=string+profile[l];
	            }
	            else {
	                string=string+"\t"+profile[l];
	            }
	            
	        }
	        print(f, string);
	      }
	    File.close(f);
	}
	if (channels > 1) {Stack.setChannel(current_channel);}
}
	

/////**************************************************************************/////

function AnalysisForTimelapse(image_folder_name, imagenumber, timelapseID, chosen_channel, frame_or_slice_analyzed, min_frame){
	
		/*** Read the metadata file to know what to analyse ***/
		types = ReadInfo_type(image_folder_name); //array of char with type of channel
		nb_bands = ReadInfo_bands(image_folder_name); //array of int with number of bands in channels
		
		clusterIDs = Save_sarcomere_length_data_timelapse(image_folder_name, imagenumber, timelapseID, chosen_channel, types, nb_bands, 
																				frame_or_slice_analyzed, min_frame);
		Concatenated_data_timelapse(image_folder_name, imagenumber, timelapseID, types, nb_bands, clusterIDs, frame_or_slice_analyzed, min_frame, chosen_channel);
		
		
		
		// Deletes all internal files
		list = getFileList(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal");
		for (i = 0; i < list.length; i++) {
			temp_value_to_avoid_output_of_function = File.delete(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+
																	File.separator + "internal" + File.separator + list[i]);}

		//File.delete gives "1" as an output when deleting a file, which is shown in log, unless stored in a variable, hence the following line
		temp_value_to_avoid_output_of_function =File.delete(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal");
}

/////**************************************************************************/////

function Save_sarcomere_length_data_timelapse(image_folder_name, imagenumber, timelapseID, chosen_channel, types, nb_bands, frame_or_slice_analyzed, min_frame){
	//returns string with filename1 \n sarcomere length \n x number of zdisk-1, filename2 \n etc...
	
	if(substring(frame_or_slice_analyzed, 0, 1)=="f"){ frame_or_slice_analyzed = "frame";}
	else{frame_or_slice_analyzed = "slice";}
	
	sarcomere_for_concatenated_data = "filename	timelapseID	repeats	"+ frame_or_slice_analyzed + "	pattern_or_sarcomere_length"+"\n";
	sarcomere_length = newArray();
	time_array = newArray();
	
	positions_for_clusters = newArray();
	time_array_for_clusters = newArray();
	repeats_for_clusters = newArray();
	normalized_positions_for_clusters = newArray();
	
	//chosen_channel specify which channel is used as reference
	
	// to simplify tracking of features, the profiles are normalized. It starts by getting the profile length for this purpose
	
	profile_lengths_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse" + File.separator + "internal" + File.separator + "profile_lengths.txt");
	rows=split(profile_lengths_file, "\n");
	profile_lengths = newArray(rows.length);
	for(m=0; m<rows.length; m++){
			profile_lengths[m] = parseFloat(rows[m]);}
	
			//open files and extract data
	time = 1;
	while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal" + File.separator + imagenumber +
								"_localizations_channel_" + chosen_channel + "_timelapse_" + timelapseID + "_t_" + time +".txt")==1)
		{
		localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal" + File.separator + imagenumber +
								"_localizations_channel_" + chosen_channel + "_timelapse_" + timelapseID + "_t_" + time +".txt");

		rows=split(localization_file, "\n");
		refs = newArray(rows.length);
		sub_sarcomere_length = newArray(rows.length-1);
		
		for(m=0; m<rows.length; m++){
			elements=split(rows[m],"\t");
			
			if ((types[chosen_channel-1] == "a") || (types[chosen_channel-1] == "q")) {refs[m] = parseFloat(elements[1]);}// peak in center of actin pattern profile
			
			else if ( (types[chosen_channel-1] == "i") || (types[chosen_channel-1] == "v") || (types[chosen_channel-1] == "s") ){
				//mean in array statistics give the average position of bands, used here as the reference
				Array.getStatistics(elements, min, max, ref_position, stdDev);
				refs[m] = ref_position;}
				
			else if (types[chosen_channel-1] == "b"){
				Array.getStatistics(Array.trim(elements, elements.length/2), min, max, ref_position, stdDev);//average of positions, exclude fitting parameters from analysis
				refs[m] = ref_position;}
				
			else{Dialog.create("There is a problem...");
				Dialog.addMessage("I cannot use this channel to extract the pattern/sarcomere size.");
				Dialog.addMessage("Please try again with another channel.\n \n");
				Dialog.addMessage("You might want to follow our tutorials - press the help button.");
				Dialog.show;			
				File.delete(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal");		
				exit;}
			}
				
			
		for(m=0; m<rows.length-1; m++){
			sub_sarcomere_length[m] = refs[m+1] - refs[m];
			//"filename	timelapseID	repeats	"+ frame_or_slice_analyzed + "	sarcomere_length"+"\n";
			sarcomere_for_concatenated_data = sarcomere_for_concatenated_data + imagenumber +"\t"+ timelapseID +"\t"+ toString(m+1) + "-" + toString(m+2) +"\t"+ 
												toString(time + min_frame - 1) + "\t"+ toString(sub_sarcomere_length[m]) + "\n";
			time_array = Array.concat(time_array, time + min_frame - 1);
			}
			
		//sarcomere_for_concatenated_data = sarcomere_for_concatenated_data;//adds a line each time it changes to another file
		sarcomere_length = Array.concat(sarcomere_length,sub_sarcomere_length);
		
		temp_time = newArray(refs.length);
		Array.fill(temp_time, time + min_frame - 1);
		
		positions_for_clusters =  Array.concat(positions_for_clusters, refs);
		time_array_for_clusters = Array.concat(time_array_for_clusters, temp_time);
		repeats_for_clusters = Array.concat(repeats_for_clusters, Array.getSequence(rows.length)); //repeats start at 0
		
		norm_refs = newArray(refs.length);
		for (m = 0; m < refs.length; m++) {
			norm_refs[m] = refs[m]/profile_lengths[time-1];
			}

		normalized_positions_for_clusters = Array.concat(normalized_positions_for_clusters, norm_refs);
		
		time = time + 1;
				}

	//save sarcomere length in a single file
	File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse" + File.separator + "pattern_or_sarcomere_lengths_" + timelapseID + ".txt")
	f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse" + File.separator + "pattern_or_sarcomere_lengths_" + timelapseID + ".txt");
	print(f,sarcomere_for_concatenated_data);

	File.close(f);
	
	Array.getStatistics(sarcomere_length, min, max, mean_sarc_length, stdDev);
	Array.getStatistics(profile_lengths,  min, max, mean_profile_length, stdDev);
	
	epsilon = mean_sarc_length/mean_profile_length/2; //potentially let the user pick other values
	
	clusterIDs = Extract_timelapse_clusters(normalized_positions_for_clusters, time_array_for_clusters, epsilon);
	
	// Plot each cluster as a continous line
	
		Plot.create("Pattern position vs "+frame_or_slice_analyzed, frame_or_slice_analyzed, "Position");
		Plot.setColor("gray");
		
		Array.getStatistics(clusterIDs, min, max_clusterIDs, mean, stdDev);
		for(clusterID = 1; clusterID < max_clusterIDs + 1; clusterID++){
	
			cluster_time = newArray();
			cluster_positions = newArray();
			
			for(pointIndex = 0; pointIndex < clusterIDs.length; pointIndex++){
				if(clusterIDs[pointIndex] == clusterID){
					cluster_positions = Array.concat(cluster_positions, positions_for_clusters[pointIndex]);
					cluster_time = Array.concat(cluster_time,time_array_for_clusters[pointIndex]);
					}
				}
			Plot.add("line", cluster_time, cluster_positions);}
		
		Plot.getLimits(xMin, xMax, yMin, yMax);
		Plot.setLimits(xMin - (xMax-xMin)/10, xMax + (xMax-xMin)/10, 0, yMax + (yMax-yMin)/10);
	Plot.show();
	
	
	// displays an histogram of sarcomere/pattern lengths
	Plot.create("Pattern size vs "+frame_or_slice_analyzed, frame_or_slice_analyzed, "Pattern size");
	Plot.setColor("gray");
	Plot.add("circle", time_array, sarcomere_length);
	
	// generate a average pattern length over time
	avg_time = newArray();
	avg_sarc_size = newArray();
	current_sarc_size = newArray();
	current_time = time_array[0];
	
	for (t = 0; t < time_array.length; t++) {
		if(time_array[t] == current_time){
			current_sarc_size = Array.concat(current_sarc_size, sarcomere_length[t]);
			}
		else{Array.getStatistics(current_sarc_size, min, max, mean_sarc_size_current_time, stdDev);
			avg_sarc_size = Array.concat(avg_sarc_size,mean_sarc_size_current_time);
			avg_time = Array.concat(avg_time, current_time);
			
			current_sarc_size = newArray();
			current_sarc_size = Array.concat(current_sarc_size, sarcomere_length[t]);
			current_time = time_array[t];
			}
		}
	if(avg_time[avg_time.length -1] != current_time){
		Array.getStatistics(current_sarc_size, min, max, mean_sarc_size_current_time, stdDev);
			avg_sarc_size = Array.concat(avg_sarc_size,mean_sarc_size_current_time);
			avg_time = Array.concat(avg_time, current_time);
		}
	Plot.setLineWidth(2);
	Plot.setColor("red");
	Plot.add("line", avg_time, avg_sarc_size);
	Plot.setLineWidth(1);//reset the linewidth
	
	sorted_lengths = Array.sort(sarcomere_length);
	yMin_graph = sorted_lengths[0];
	
	//Plot.addText(mean_and_sd, 0, 0)
	Plot.setLimits(NaN, NaN, yMin_graph, NaN);
	Plot.getLimits(xMin, xMax, yMin, yMax);
	Plot.setLimits(xMin - (xMax-xMin)/10, xMax + (xMax-xMin)/10, yMin, yMax + (yMax-yMin)/10);
	Plot.show();
			
	
	return clusterIDs;	
	}
	
	
/////////////////////////////////////////////////////////////////////////////////////

function Concatenated_data_timelapse(image_folder_name, imagenumber, timelapseID, types, nb_bands, clusterIDs, frame_or_slice_analyzed, min_frame, chosen_channel){
	//Concatenate data from all files and save it in a single file per channel
	
	// first a heading to describe data
	// reminder "individual band(s)", "actin (exp. alg.)", "actin (quant. alg.)", "block", "very close individual band(s)", "single pattern", "other?")
	// with types in "iaqbvso"
	
	for (i = 0; i < types.length; i++) {
		heading = "filename	timelapseID	"+ frame_or_slice_analyzed + "	pattern"+"\t";
		analyzed_type = "iaqbvs";
		if ( analyzed_type.indexOf(types[i]) > -1) { //checks that the type of a given channel is within what can be analyzed
			chan_analyzed = i + 1;
			ch = "ch" + chan_analyzed;
			
			subtype_band = "iv";
			if (subtype_band.indexOf(types[i]) > -1){ // individuals bands or very close individual bands
				for (m = 0; m < nb_bands[i]; m++) {
					b = m + 1;
					if (b == nb_bands[i]){heading = heading + ch + "_band" + b;}
					else {heading = heading + ch + "_band" + b + "\t";}
					}}
					
			else if (types[i]=="a"){heading = heading + ch + "_left_edge" +"\t" + ch + "_highest" + "\t" + ch + "_right_edge" +"\t" + ch + "_rate_left" + "\t" + ch + "_rate_right";}
			else if (types[i]=="q"){heading = heading + ch + "_left_edge" +"\t" + ch + "_highest" + "\t" + ch + "_right_edge";}
			
			else if (types[i]=="b"){
				for (m = 0; m < nb_bands[i]; m++) {
					b = m + 1; heading = heading + ch + "_left_edge" + b + "\t";}
				for (m = 0; m < nb_bands[i]; m++) {
					b = m + 1; heading = heading + ch + "_right_edge" + b + "\t";}
				for (m = 0; m < nb_bands[i]; m++) {
					b = m + 1; heading = heading + ch + "_rate_left_edge" + b + "\t";}
				for (m = 0; m < nb_bands[i]; m++) {
					b = m + 1;
					if (b == nb_bands[i]){heading = heading + ch + "_rate_right_edge" + b;}
					else {heading = heading + ch + "_rate_left_edge" + b + "\t";}
					}}
			
			else if (types[i]=="s"){heading = heading + ch + "_pattern_position" + "\n";}
			
			if(i == chosen_channel - 1){heading = heading + "\t" + "clusterID" + "\n";}
			else{heading = heading + "\n";}
			}
		
		concat_data = heading;
		// opens a given channel
					time = 1;
					k = 0;
					while (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator + "internal" + File.separator + imagenumber +
								"_localizations_channel_" + chan_analyzed + "_timelapse_" + timelapseID + "_t_" + time +".txt")==1)
						{
						localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse"+ File.separator +
											"internal" + File.separator + imagenumber +	"_localizations_channel_" + chan_analyzed + "_timelapse_" + timelapseID + "_t_" + time +".txt");
						rows=split(localization_file, "\n"); 
						
						for (m = 0; m < rows.length; m++) {
							pattern_number = m + 1;
							if(i == chosen_channel - 1){concat_data = concat_data + imagenumber +"\t"+ timelapseID +"\t"+ (time + min_frame - 1) + "\t" + pattern_number + "\t" + rows[m] + "\t" + clusterIDs[k] +  "\n";
													k = k + 1;}
							else{concat_data = concat_data + imagenumber +"\t"+ timelapseID +"\t"+ (time + min_frame - 1) + "\t" + pattern_number + "\t" + rows[m] + "\n";}
						}
						time = time + 1;}
		
		// Saves the file	
		File.saveString(concat_data, image_folder_name + File.separator + "Analyses" + File.separator + "Timelapse" + File.separator +
						"All_localizations_channel_" + chan_analyzed + "timelapse_"+timelapseID+".txt");				
		}
}



/////////////////////////////////////////////////////////////////////////////////////

////////////// 			Tracking functions for timelapse			/////////////////

/////////////////////////////////////////////////////////////////////////////////////


function Extract_timelapse_clusters(xCoords, time, epsilon){

	// Initialize array of cluster IDs
	nPoints = xCoords.length;
	clusterIDs = newArray(nPoints);
	Array.fill(clusterIDs, -1);
	
	// Initialize cluster ID counter
	clusterID = 0;
	
	Array.getStatistics(time, min, max_time, mean, stdDev);
	
	// Iterate through each point
	for (p = 0; p < nPoints-1; p++) {// no need to vist the last point as it will be either already selected or isolated
		if(time[p] != max_time){// avoid last timepoint, which would have been treated in previous steps
	        neighbor_index = getNextNeighbor(p, xCoords, time, epsilon);
	        if (neighbor_index != -1) { // the next point is found
	        	if (clusterIDs[p] == -1){ // there is no allocated cluster yet to the current point
	        		clusterID++;
	        		clusterIDs[p] = clusterID; // cluster allocation
	        		clusterIDs[neighbor_index] = clusterID;} // same cluster allocation to the neighbor
	        		
	            else{clusterIDs[neighbor_index] = clusterIDs[p];} // the point already has an allocation, which is transfered to the neighbor
	        }
	    }
	}
	
	return clusterIDs;
}



// Function to retrieve the next neighbor of a given point
function getNextNeighbor(pointIndex, xCoords, time, epsilon) {
	Array.getStatistics(time, min, max_time, mean, stdDev);
	current_time = max_time + 1;
	if(pointIndex != xCoords.length - 1){//avoid last point on the list, which will not have a neighbor after it by definition
		
	    for (i = pointIndex + 1; i < xCoords.length; i++) {
	    	
	        if (time[pointIndex] != time[i]) {
	        	//make sure it is from a different timepoint and not last timepoint
	        	
	            dist_norm_time = abs((xCoords[i] - xCoords[pointIndex])/(time[i]-time[pointIndex]));
	            
	            if ( dist_norm_time <= epsilon && abs((time[i]-time[pointIndex])) < 20) {
	            	// the point should be closer than epsilon*(time difference) and
	            	// time difference should not be more than 5 timepoints
	            	if(time[i] <= current_time){
		            	epsilon = dist_norm_time;
		                neighbor_index = i;
		                current_time = time[i];}
	                
	                else{break;}}
	                
				else{if(neighbor_index == -1){
					neighbor_index = -1;}}}
    			}
	}
    else{neighbor_index = -1;}
    
    return neighbor_index;
}



/////**************************************************************************/////
/////**************************************************************************/////
/////**************************************************************************/////
/////**********************                              **********************/////
/////**********************   ROI analysis functions     **********************/////
/////**********************                              **********************/////
/////**************************************************************************/////
/////**************************************************************************/////
/////**************************************************************************/////
/////**************************************************************************/////


function Introduction_ROIs(){
	
	
	// Check if there is an image opened
	
	list = getList("image.titles");
	if (list.length == 0){
	  	Dialog.create("There is a problem...");
		Dialog.addMessage("No image can be found.\nOpen an image to analyze and try again.");
		Dialog.show;
		exit;}
	
	
		if(roiManager("size") > 0){
						// ask the user if the ROI manager can be emptied
						showMessageWithCancel("The ROI manager is not empty...", "It seems like your ROI manager is not empty.\n"+
						"Is it ok for you if I delete the current selection(s) from the ROI manager?\n \n" +
						"If you used PatternJ on a previous image, selections are already saved.\nI just make some space for your timelapse selections: simply press \"OK\".\n \n" +
						"If these selections are not from PatternJ, but you want to keep them\nand did not save them yet, press \"Cancel\"");
						
						roiManager("reset");//deletes all current selections if users clicks "OK"
						}
		
		Dialog.createNonBlocking("Select your ROI file");
					Dialog.addMessage("Select your ROI file", 15, "#0000ff");
					Dialog.addMessage("If your file contains one selection, its extension is .roi, otherwise it is a ZIP file.");
					Dialog.addFile("your file", "a ZIP of roi file");
					Dialog.show;
					
		ROI_file_path = Dialog.getString();
		
		roiManager("open", ROI_file_path);
		
		ROI_ID = File.getName(ROI_file_path);
		
		return ROI_ID;

}


/////**************************************************************************/////

function Extract_and_save_ROIs(image_folder_name, imagenumber, ROI_ID){
	
	ROI_count = roiManager("count");
	
	Plot.create("Profile checker for ROIs: "+imagenumber, "Pixel position", "Normalized intensity");
	
	//*** Read the metadata file to know what to analyse ***//
		types = ReadInfo_type(image_folder_name); //array of char with type of channel
		nb_bands = ReadInfo_bands(image_folder_name); //array of int with number of channels
		channel_Z_or_M = ReadInfo_channel_ZM(image_folder_name); //array of char ("Z" or "M") with info on data centered on Z-disk or M-line
		drawn_Z_or_M = ReadInfo_drawnZM(image_folder_name); //returns 0 if from (edge to edge)/(Z-disk to Z-disk), 1 if from (center to center)/(M-line-to-M-line)
		
	//*** Extra info on stack ***//
		Stack.getDimensions(width, height, channels, slices, frames);
		getPixelSize(unit, pixelWidth, pixelHeight);
		
		Plotcolors_profile = Profile_colors_timelapse(imagenumber, channels);
		Plotcolors_adder = Plot_adder_colors_timelapse(imagenumber, channels);
	//*** Extract & save positions ***//
	
	for (i = 0; i < ROI_count; i++) {
		showStatus("PatternJ: analysis is " +round(i/ROI_count*100) + "% complete");
		RoiManager.select(i);
		
		ROI_number = i+1;
		
		for (j=1; j<channels + 1; j++){
			if (channels > 1) {
				Stack.setChannel(j);}
			
			profile = getProfile();
			avgSizeSarcomere = autoCorr(profile);//given in pixels
			posPattern = crossCorr(profile, avgSizeSarcomere, channel_Z_or_M[j-1], drawn_Z_or_M);
						//image_folder_name, channel, profile, type, nb_band, avgSizeSarcomere, posPattern, channel_ZM, temp, timelapseID) 
						//temp = 1 will save data in "temp" files, not used in analysis 
			Localization(image_folder_name, j, profile, types[j-1], nb_bands[j-1], avgSizeSarcomere, posPattern, channel_Z_or_M[j-1],3,ROI_ID, ROI_number); 
			//0 at the end stands for saving files with extracted positions in analysis/internal folder
			
			}
		
		
		
		//*** Save intensity in ROI ***//
		RoiManager.select(i);
		Save_intensity_in_ROI(image_folder_name, imagenumber, ROI_ID, ROI_number);
		
		//*** Display positions in a graph ***//
		RoiManager.select(i);
		Profile_checker_timelapse(imagenumber, Plotcolors_profile);
		Position_in_plot_adder_ROI(image_folder_name,imagenumber,types, pixelWidth, ROI_ID, ROI_number, Plotcolors_adder);
		}
		
	
	//Plot.show;
	//return timelapseID;
		
	CheckimageStatus_for_ROIs_Analysis(image_folder_name, imagenumber, ROI_ID);
	// adds the imagenumber with the ROI name to the list of image with extracted features
	// this way it can be used for analysis later on
}


/////**************************************************************************/////

function Position_in_plot_adder_ROI(image_folder_name,imagenumber,types, pixelWidth, ROI_ID, ROI_number, Plotcolors) {//temp = 1 will use "temp" files

	///*** Plot the positions extracted in profiles in the profile graph ***///
	
	Stack.getDimensions(width, height, channels, slices, frames);
	
	// plot positions found
	
	for (i = 0; i < types.length; i++) {
			Plot.setColor(Plotcolors[i]);

			chann = i + 1;

			localization_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator +
													imagenumber + "_ROI_" + ROI_ID + "_localizations_channel_" + chann + "_" + ROI_number +".txt");
			
			rows=split(localization_file, "\n");
			
			if (rows.length == 0) {//finds an empty result
				Dialog.create("There is a problem...");
				Dialog.addMessage("Sorry, I cannot fit your data.");
				Dialog.addMessage("Consider trying another selection or one of the other fitting methods.");
				Dialog.show;
				exit;
			}
			
			else {
				for(m=0; m<rows.length; m++){
					elements=split(rows[m],"\t");
					if ((types[i] == "i") | (types[i] == "q") | (types[i] == "v")| (types[i] == "s")) {//type individual bands or type actin quantile algorithm
						end = elements.length;}
	
					else if (types[i] == "a") {//type actin
						end = 3;}
	
					else if (types[i] == "b") {//type individual block
						end = elements.length/2;}
						
						for (l = 0; l < end; l++) {
							x1 = 1/pixelWidth*elements[l];
							xValues = newArray(x1,x1);
							yValues = newArray(channels-1-i,channels-i);
							Plot.add( "line", xValues, yValues);}
							}
						}
			}
			Plot.appendToStack;
			}

/////**************************************************************************/////


function CheckimageStatus_for_ROIs_Analysis(image_folder_name, imagenumber, ROI_ID){
	/// Check if extraction on image with set of ROIs already occured
	
	if (File.exists(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt")!=1) {
		File.saveString(imagenumber + "_ROI_" + ROI_ID + "\n", image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt");}

	else {
		//Open image name file
	image_name_file = File.openAsString(image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt");

	//Rows into an array of strings
	rows=split(image_name_file, "\n"); 

	add_image = 0;
	for (i = 0; i < rows.length; i++) {
		if (imagenumber + "_ROI_" + ROI_ID == rows[i]) {add_image = add_image + 1;}
	}

	if (add_image == 0) {
	File.append(imagenumber + "_ROI_" + ROI_ID + "\n", image_folder_name + File.separator + "Analyses" + File.separator + "internal" + File.separator + "image_names.txt");	}
	}
}


/////**************************************************************************/////


function Save_intensity_in_ROI(image_folder_name, imagenumber, ROI_ID, ROI_number){
//Save the 2D intensity information of the ROI
	
	if (File.exists(image_folder_name + File.separator + "Analyses"+ File.separator + "ROI_intensities")!=1) {
			File.makeDirectory(image_folder_name + File.separator + "Analyses"+ File.separator + "ROI_intensities");}
	
	run("Interpolate", "interval=1 smooth");    //interpolate the ROI with 1 pixel
	Roi.getCoordinates(x,y);    //get the positions of each point
	
	////// Local segments perpendicular to the junction are used to obtain the profile perpendicular to the segment drawn by the user, every pixel along the segment
	
	getLine(x1, y1, x2, y2, lineWidth); //get the linewidth used
	
	for (i=1; i<channels + 1; i++)
	{    if (channels > 1) {Stack.setChannel(i);}
	
	// create file for profile on channel i
	File.saveString("", image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities"+ File.separator + imagenumber + "_ROI_" +
				  						ROI_ID + "_2D_profile_channel" + i + "_" + ROI_number +".txt")
	
	    f = File.open(image_folder_name + File.separator + "Analyses" + File.separator + "ROI_intensities"+ File.separator + imagenumber + "_ROI_" +
				  						ROI_ID + "_2D_profile_channel" + i + "_" + ROI_number +".txt");
	
	// create unitary segments to define profiles perpendicular to the segment drawn
	   for (k=0; k<lengthOf(x)-2; k++)
	    {        if (k<3) {
	            norm = sqrt((x[0]-x[6])*(x[0]-x[6])+(y[0]-y[6])*(y[0]-y[6]));
	            unit_perp_x = (-(y[6]-y[0])/norm);
	            unit_perp_y = ((x[6]-x[0])/norm);
	            }
	            else if (k>lengthOf(x)-4) {
	            norm = sqrt((x[lengthOf(x)-7]-x[lengthOf(x)-1])*(x[lengthOf(x)-7]-x[lengthOf(x)-1])+(y[lengthOf(x)-7]-y[lengthOf(x)-1])*(y[lengthOf(x)-7]-y[lengthOf(x)-1]));
	            unit_perp_x = (-(y[lengthOf(x)-1]-y[lengthOf(x)-7])/norm);
	            unit_perp_y = ((x[lengthOf(x)-1]-x[lengthOf(x)-7])/norm);
	            }
	            else {
	            norm = sqrt((x[k-3]-x[k+3])*(x[k-3]-x[k+3])+(y[k-3]-y[k+3])*(y[k-3]-y[k+3]));
	            unit_perp_x = (-(y[k+3]-y[k-3])/norm);
	            unit_perp_y = ((x[k+3]-x[k-3])/norm);
	            }
	                        
	        // From the reference line, creates a segment (profile line) whose middle is a given point of the reference line,
	        // its length is the linewidth and  it is locally perpendicular to the reference line
	        if(lineWidth == 0){lineWidth = 1;}
	        lengthofprofile = lineWidth;
	        profile=newArray(lengthofprofile);
	
	        for (l=0; l<lengthOf(profile); l++)
	        {    //interpolation of the value of pixel along the profile line
	            xM = x[k] + (l-(lengthOf(profile)-1)/2)*unit_perp_x;
	            yM = y[k] + (l-(lengthOf(profile)-1)/2)*unit_perp_y;
	
	            espilon_x = (xM-floor(xM));
	            espilon_y = (yM-floor(yM));
	                        
	            profile[l] = (1-espilon_x)*(1-espilon_y)*getPixel(floor(xM),floor(yM))
	                        +(espilon_x)*(1-espilon_y)*getPixel(floor(xM)+1,floor(yM))
	                        +(espilon_x)*(espilon_y)*getPixel(floor(xM)+1,floor(yM)+1)
	                        +(1-espilon_x)*(espilon_y)*getPixel(floor(xM),floor(yM)+1);
	        }
	
	        string="";
	        for (l=0; l<lengthOf(profile); l++) {
	            if (l==0) {
	                string=string+profile[l];
	            }
	            else {
	                string=string+"\t"+profile[l];
	            }
	            
	        }
	        print(f, string);
	      }
	    File.close(f);
	}
}