/*************************************************************************************************** 	
	Project: 		Validation of a theoretically motivated approach to measuring childhood socioeconomic 
					circumstances in the Health and Retirement Study 

	Programmer: 	Anusha M. Vable

	Description: 	This code pulls in variables from various HRS core data sets, the tracker data set, 
					and the RAND data set, and cleans them in preparation for exploratory factor analysis 
					for the social capital and financial capital scales.  The human capital
					imputations are done in a separate SAS file, so I don't pull any parental education 
					variables in this file. 	
			
					While responding to reviewer comments (i.e. after we thought we were done with the 
					analysis), we found that many of the variables we used were first asked in an 
					experimental module in 1996.  We additionally realized that a) the response options in 
					the experimental module were different for some varaiblees and usually there were more 
					response options in the 1996 version of the questions, and b) there were additional 
					questions asked in the experimental module that weren't incorporated into the core 
					questionniare.  I clean the variables in the 1996 module towards the end of this file. 

					The code for Appendix Table A1 is at the end of this file. 
/***************************************************************************************************/ 	

%let drivename = Z:\Dropbox; * Anusha;
*%let drivename= C:\Users\Paoventure\Dropbox;

run;

libname rawdata "&drivename.\HRSPublicUseData\HRSRawData\RAND";
libname rawexit "&drivename.\HRSPublicUseData\HRSRawData\Exits";
libname rawcore "&drivename.\HRSPublicUseData\HRSRawData\Core";
libname hrsclean "&drivename.\HRSPublicUseData\HRSCleanData";
libname CDI "&drivename.\Research Projects\Childhood SES in HRS";
*libname FS "&drivename.\Childhood SES in HRS\Paola\Finalized Outcome documentation";


options fmtsearch=(rawdata) nofmterr;



/* Variable Lists for Importation -- import RAND b/c I want the HHIDPN variable*/ 
%let varlist_rand = 
			HHID PN  HHIDPN 
			;
run;


%let varlist_tkr = 
			HHID PN  
			;
run; 

/* Import Rand data set */
data rand;
	set rawdata.rndhrs_n (keep = &varlist_rand);
run; 

/* Import Tracker 2010 data set */
	data tracker10;
		set hrsclean.trk2010 (keep = &varlist_tkr);
		proc sort; by hhid pn;
	run;

*********************************************************
/* PULL IN POTENTIAL VARIABLES FROM HRS CORE DATASETS  */ 
*********************************************************;

/*1996 core files*/
	data h96m_r;  
		set rawcore.h96m_r;
		keep hhid pn 
				e5654m 		/* father's occupation */
				e5655 		/* how well off family response options: 1 - 5 */ 
				e5657_1 	/* father lose job */ 
				e5657_2		/* father / family lose business */ 
				e5657_3		/* father / family declare bankrupcy */		
				e5657_4		/* move for financial reasons */ 
				e5657_5		/* recieved financial help from relatives */ 
				e5658 		/* live with both parents */
				e5659 		/* why  not both parents */ 
				e5660 		/* live with step parents */
				e5661 		/* live with grandparents */ 
			; 
		proc sort; by hhid pn;
	run;

/*1998 core file*/ 
	data h98a_r;  
		set rawcore.h98a_r;
		keep hhid pn 
			f997hm 	/* father's occupation */ 
			f993 	/* fam ses */
			F994 	/* fin move */ 
			F995 	/* fin help */
			F996 	/* father lose job */ 
			; 
		proc sort; by hhid pn;
	run;
		proc freq data = h98a_r; 
			table f997hm f993 F994 F995 F996;
		run; 

/*1998 exit file*/  
	data x98a_r;  
		set rawexit.x98a_r;
		keep hhid pn 
			q997M 	/* father's occupation */
			q996 	/* father lose job */
			; 
		proc sort; by hhid pn;
	run;

/*2000 core file*/
	data h00a_r;  
		set rawcore.h00a_r;
		keep hhid pn  
			G1084M 	/* father's occupation */ 
			G1080 	/* fam ses */ 
			G1081 	/* fin move */ 
			G1082 	/* fin help */ 
			G1083 	/* father lose job */ 
			G1085 	/* live with grandparents */ 
			; 
		proc sort; by hhid pn;
	run;

			
/* 2000 exit files */ 
	data x00a_r;  
		set rawexit.x00a_r;
		keep hhid pn 
			R1069M 	/* father's occupation */ 
			R1068 	/* father lose job */ 
			R1070 	/* live with grandparents */
			; 
		proc sort; by hhid pn;
	run;
	
/* 2002 core file */ 
	data h02b_r;  
		set rawcore.h02b_r;
		keep hhid pn  
			HB024M 	/* father's occupation */ 
			Hb020 	/* fam ses */ 
			HB021 	/* fin move */ 
			HB022 	/* fin help */
			HB023 	/* father lose job */ 
			HB025 	/* live with grand parent */ 
			; 
		proc sort; by hhid pn;
	run;


/* 2002 exit file */ 
	data x02b_r;  
		set rawexit.x02b_r;
		keep hhid pn 
			SB020 	/* fam ses */ 
			SB021 	/* fin move */
			SB022 	/* fin help */ 
			SB023 	/* father lose job */ 
			SB025 	/* live with grandparents */
			;
		proc sort; by hhid pn;
	run;

/* 2004 core files */
	data h04b_r;  
		set rawcore.h04b_r;
		keep hhid pn 
			JB024M 	/* father's occupation */ 
			JB020 	/* fam ses */ 
			JB021 	/* fin move */ 
			JB022 	/* fin help */ 
			JB023 	/* father lose job */ 
			JB025 	/* live with grandparents */ 
			; 
		proc sort; by hhid pn;
	run; 


/*2004 exit file*/   
	data x04b_r;  
		set rawexit.x04b_r;
		keep hhid pn 
			TB020 	/* fam ses */ 
			TB021 	/* fin move */ 
			TB022 	/* fin help */ 
			TB023 	/* father lose job */ 
			TB025 	/* live with grandparents */ 
			;
		proc sort; by hhid pn;
	run;

/* 2006 core file */ 
	data h06b_r;  
		set rawcore.h06b_r;
		keep hhid pn 
			KB024M 	/* father's occupation */
			KB020 	/* fam ses */ 
			KB021 	/* fin move */ 
			KB022 	/* fin help */ 
			KB023 	/* father lose job */ 
			KB025 	/* live with grandparents */  
			KB088 	/* mother work during childhood */
			; 
		proc sort; by hhid pn;
	run; 


/* 2006 exit file */
	data x06b_r;  
		set rawexit.x06b_r;
		keep hhid pn 
			UB024M 	/* father's occupation */
			UB020 	/* fam ses */ 
			UB021 	/* fin move */ 
			UB022 	/* fin help */ 
			UB023 	/* father lose job */ 
			UB025 	/* live with grandparents */ 
			UB088 	/* mother work during childhood */
			; 
		proc sort; by hhid pn;
	run; 


options fmtsearch=(rawdata) nofmterr;
/*2008 core file*/  
	data h08b_r;  
		set rawcore.h08b_r;
		keep hhid pn 
			LB020 	/* fam ses */ 
			LB021 	/* fin move */ 
			LB022 	/* fin help */ 
			LB023 	/* father lose job */ 
			LB025 	/* live with grandparents */ 
			LB088 	/* mother work during childhood */
			;
		proc sort; by hhid pn;
	run;


/*2008 leave behind questionnaire*/  
	data h08lb_r;  
		set rawcore.h08lb_r;
		keep hhid pn 
			LLB037H /* amt time / attention from mother */
			LLB037I /* effort from mother */ 
			LLB037J	/* amt mother teach about life */ 
			; 
		proc sort; by hhid pn;
	run;


/*2008 exit file*/ 
	data x08b_r;  
		set rawexit.x08b_r;
		keep hhid pn 
			VB024M 	/* father's occupation */
			VB020 	/* fam ses */ 
			VB021 	/* fin move */ 
			VB022 	/* fin help */ 
			VB023 	/* father lose job */ 
			VB025 	/* live with grandparents */ 
			VB088 	/* mother work during childhood */
			; 
		proc sort; by hhid pn;
	run; 

/*2010 core file */
	data h10lb_r;  
		set rawcore.h10b_r;
		keep hhid pn 
			MB024M 	/* father's occupation */
			MB020 	/* fam ses */ 
			MB021 	/* fin move */ 
			MB022 	/* fin help */ 
			MB023 	/* father lose job */ 
			MB025 	/* live with grandparents */ 
			MB088 	/* mother work during childhood */
			; 
		proc sort; by hhid pn;
	run; 


* merge all data sets together by hhid and pn;
	data merged;
		merge 	h96m_r
				h98a_r
				x98a_r
				h00a_r
				x00a_r
				h02b_r
				x02b_r
				h04b_r
				x04b_r
				h06b_r
				x06b_r
				h08b_r
				h08lb_r
				x08b_r
				h10lb_r
				
				tracker10 (in = keep)
				rand
				; 
		by hhid pn;
		if keep; 
	run;
options nofmterr;

/* In this data step, I rename all the variables to make my life easier.  "s_" denotes values that are self-reported, 
and "p_" denotes variables that are proxy reported, which came from the exit files.  I put the year
at the end of the variable name */

	data merged2;
		set merged; 
		rename 	/* father's occupation */ 
				e5654m = s_focc96
				f997hm = s_focc98
				g1084m = s_focc00
				hb024m = s_focc02
				jb024m = s_focc04
				kb024m = s_focc06
				mb024m = s_focc10

				q997m = p_focc98
				r1069m = p_focc00
				ub024m = p_focc06
				vb024m = p_focc08

				/* family SES */
				f993 = s_famses98
				g1080 = s_famses00
				hb020 = s_famses02
				jb020 = s_famses04
				kb020 = s_famses06
				lb020 = s_famses08
				mb020 = s_famses10

				sb020 = p_famses02
				tb020 = p_famses04
				ub020 = p_famses06
				vb020 = p_famses08

				/* did family move for financial reasons */
				f994 = s_finmove98
				g1081 = s_finmove00
				hb021 = s_finmove02
				jb021 = s_finmove04
				kb021 = s_finmove06
				lb021 = s_finmove08
				mb021 = s_finmove10

				sb021 = p_finmove02
				tb021 = p_finmove04
				ub021 = p_finmove06
				vb021 = p_finmove08

				/* did family recieve financial help from relatives */ 
				f995 = s_finhelp98
				g1082 = s_finhelp00
				hb022 = s_finhelp02
				jb022 = s_finhelp04
				kb022 = s_finhelp06
				lb022 = s_finhelp08
				mb022 = s_finhelp10
				 
				sb022 = p_finhelp02
				tb022 = p_finhelp04
				ub022 = p_finhelp06
				vb022 = p_finhelp08 

				/* did father lose job for sevaral months */
				f996 = s_losejob98
				g1083 = s_losejob00
				hb023 = s_losejob02
				jb023 = s_losejob04
				kb023 = s_losejob06
				lb023 = s_losejob08
				mb023 = s_losejob10

				q996 = p_losejob98
				r1068 = p_losejob00
				sb023 = p_losejob02
				tb023 = p_losejob04
				ub023 = p_losejob06
				vb023  = p_losejob08 

				/* did mom work */ 
				kb088 = s_momwork06 
				lb088 = s_momwork08
				mb088 = s_momwork10
				
				ub088 = p_momwork06
				vb088 = p_momwork08

				/* did respondent live with grandparents during childhood */
				e5661 = s_gramps96
				g1085 = s_gramps00
				hb025 = s_gramps02
				jb025 = s_gramps04
				kb025 = s_gramps06
				lb025 = s_gramps08
				mb025 = s_gramps10

				r1070 = p_gramps00
				sb025 = p_gramps02
				tb025 = p_gramps04
				ub025 = p_gramps06
				vb025 = p_gramps08 
				
				/* did respondent live with both parent growing up 	
				e5658 = bothparents 
				e5660 = stepparents*/

				/* did mom pay attention to respondent */
				llb037h = m_atten

				/* did mom put effort into upbringing */
				llb037i = m_effort 

				/* did mom teach respondent about life */ 
				llb037j = m_life
				;
	run; 


/* In this data step, I create and clean the financial captial and social capital variables.  I use the first response recorded by the respondnet, 
	then the proxy-reported measure if there isn't a self-reported measure. */

options fmtsearch=(rawdata) nofmterr;
	data analysis_vars;
		set merged2;

	/* Father's occupation classification; see Appendix Table A2 for more details */  
		/* father's occupation in 6 categories:
			1) Executives and managers
			2) Professional specilty 
			3) Sales and admin
			4) Protection services and armed forced
			5) cleaning, building, food prep and personal services
			6) production, construction, and operation occupations */

			focc_cat = .; * this is the variable for father's occupation categories; 

			* 1996 core data, occupation codes based on 1980 census classification; 
				if s_focc96 = 1 then focc_cat = 1; 
				if s_focc96 in (2,8) then focc_cat = 2; 
				if s_focc96 in (3,4) then focc_cat = 3; 
				if s_focc96 in (6,17) then focc_cat = 4; 
				if s_focc96 in (5,7,9) then focc_cat = 5; 
				if s_focc96 in (10,11,12,13,14,15,16) then focc_cat = 6; 
				if s_focc96 > 30 then focc_cat = .; 
			
			* 1998 core data, occupation codes based on 1980 census classification; 
				if focc_cat = . then do; 
					if s_focc98 = 1 then focc_cat = 1; 
					if s_focc98 in (2,8) then focc_cat = 2; 
					if s_focc98 in (3,4) then focc_cat = 3; 
					if s_focc98 in (6,17) then focc_cat = 4; 
					if s_focc98 in (5,7,9) then focc_cat = 5; 
					if s_focc98 in (10,11,12,13,14,15,16) then focc_cat = 6; 
					if s_focc98 > 30 then focc_cat = .; 
				end; 

			* 2000 core data, occupation codes based on 1980 census classification; 
				if focc_cat = . then do; 
					if s_focc00 = 1 then focc_cat = 1; 
					if s_focc00 in (2,8) then focc_cat = 2; 
					if s_focc00 in (3,4) then focc_cat = 3; 
					if s_focc00 in (6,17) then focc_cat = 4; 
					if s_focc00 in (5,7,9) then focc_cat = 5; 
					if s_focc00 in (10,11,12,13,14,15,16) then focc_cat = 6; 
					if s_focc00 > 30 then focc_cat = .; 
				end; 

			* 2002 core  data, occupation codes based on 1980 census classification; 
				if focc_cat = . then do; 
					if s_focc02 = 1 then focc_cat = 1; 
					if s_focc02 in (2,8) then focc_cat = 2; 
					if s_focc02 in (3,4) then focc_cat = 3; 
					if s_focc02 in (6,17) then focc_cat = 4; 
					if s_focc02 in (5,7,9) then focc_cat = 5; 
					if s_focc02 in (10,11,12,13,14,15,16) then focc_cat = 6; 
					if s_focc02 > 30 then focc_cat = .; 
				end;

			* 2004 core data, occupation codes based on 1980 census classification;  
				if focc_cat = . then do; 
					if s_focc04 = 1 then focc_cat = 1; 
					if s_focc04 in (2,8) then focc_cat = 2; 
					if s_focc04 in (3,4) then focc_cat = 3; 
					if s_focc04 in (6,17) then focc_cat = 4; 
					if s_focc04 in (5,7,9) then focc_cat = 5; 
					if s_focc04 in (10,11,12,13,14,15,16) then focc_cat = 6; 
					if s_focc04 > 30 then focc_cat = .; 
				end;

					
			* SWITCH TO 2000 CENSUS CLASSIFICATION; 
			* 2006 core  data, occupation codes based on 2000 census classification; 
				if focc_cat = . then do; 
					if s_focc06 in (1,2,3) then focc_cat = 1; 
					if s_focc06 in(4,5,6,7,8,9,10,11,12) then focc_cat = 2; 
					if s_focc06 in (17,18) then focc_cat = 3; 
					if s_focc06 in (13,25) then focc_cat = 4; 
					if s_focc06 in (14,15,16) then focc_cat = 5; 
					if s_focc06 in (19,22,20,21,23,24) then focc_cat = 6; 
				end;


			* SWITCH TO 2010 CENSUS CLASSIFICATION;
			* 2010 core data, occupation codes should based on 2010 census classification according to the documentation, 
					however the 2010 classification has 23 categories, and these data have 25 categories, same as the 2000 classification.
					So, I'm assuming they have the 2000 classification;
				if focc_cat = . then do; 
					if s_focc10 in (1,2,3) then focc_cat = 1; 
					if s_focc10 in(4,5,6,7,8,9,10,11,12) then focc_cat = 2; 
					if s_focc10 in (17,18) then focc_cat = 3; 
					if s_focc10 in (13,25) then focc_cat = 4; 
					if s_focc10 in (14,15,16) then focc_cat = 5; 
					if s_focc10 in (19,22,20,21,23,24) then focc_cat = 6; 
				end;

			* SWITCH TO exit files, back to 1980 census classification.  This variable is not in the 2002, 2004, or 2008 exit files; 
																		
			* exit files, proxy report of father's occupation; 
				* 1980 census classifcation;
				* 1998 exit data, occupation codes based on 1980 census classification; 
					if focc_cat = . then do; 
						if p_focc98 = 1 then focc_cat = 1; 
						if p_focc98 in (2,8) then focc_cat = 2; 
						if p_focc98 in (3,4) then focc_cat = 3; 
						if p_focc98 in (6,17) then focc_cat = 4; 
						if p_focc98 in (5,7,9) then focc_cat = 5; 
						if p_focc98 in (10,11,12,13,14,15,16) then focc_cat = 6; 
						if p_focc98 > 30 then focc_cat = .; 
					end;
					

				* 2000 exit data, occupation codes based on 1980 census classification; 
					if focc_cat = . then do; 
						if p_focc00 = 1 then focc_cat = 1; 
						if p_focc00 in (2,8) then focc_cat = 2; 
						if p_focc00 in (3,4) then focc_cat = 3; 
						if p_focc00 in (6,17) then focc_cat = 4; 
						if p_focc00 in (5,7,9) then focc_cat = 5; 
						if p_focc00 in (10,11,12,13,14,15,16) then focc_cat = 6; 
						if p_focc00 > 30 then focc_cat = .; 
					end;
		
				* SWITCH TO 2000 CENSUS CLASSIFICATION; 
				* 2006 exit data, occupation codes based on 2000 census classification; 
					if focc_cat = . then do; 
						if p_focc06 in (1,2,3) then focc_cat = 1; 
						if p_focc06 in(4,5,6,7,8,9,10,11,12) then focc_cat = 2; 
						if p_focc06 in (17,18) then focc_cat = 3; 
						if p_focc06 in (13,25) then focc_cat = 4; 
						if p_focc06 in (14,15,16) then focc_cat = 5; 
						if p_focc06 in (19,22,20,21,23,24) then focc_cat = 6;
					end;
	 
				* 2008 exit data, occupation codes based on 2000 census classification; 
					if focc_cat = . then do; 
						if p_focc08 in (1,2,3) then focc_cat = 1; 
						if p_focc08 in(4,5,6,7,8,9,10,11,12) then focc_cat = 2; 
						if p_focc08 in (17,18) then focc_cat = 3; 
						if p_focc08 in (13,25) then focc_cat = 4; 
						if p_focc08 in (14,15,16) then focc_cat = 5; 
						if p_focc08 in (19,22,20,21,23,24) then focc_cat = 6;
					end;
				
	* family ses; 
		* set to missing after each step so that if question is answered in a later wave, we replace the missing with data; 
			famses2 =  s_famses98; if famses2 > 6 then famses2 = .;  
			if famses2 = . then famses2 = s_famses00; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = s_famses02; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = s_famses04; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = s_famses06; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = s_famses08; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = s_famses10; if famses2 > 6 then famses2 = .; 

			if famses2 = . then famses2 = p_famses02; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = p_famses04; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = p_famses06; if famses2 > 6 then famses2 = .; 
			if famses2 = . then famses2 = p_famses08; if famses2 > 6 then famses2 = .;  

			famses = famses2; * need famses2 for the compairson analysis b/c Luo set those who said SES varied to missing; 
				* recode varied family ses to average ses for our analysis;
				if famses = 6 then famses = 2; 
				* recode famses as follows 1 = above average ses, 2 = average / varied, 3 = poor; 
				if famses = 3 then famses = 2;
				if famses = 5 then famses = 3; 
		

	* move for financial reasons; 
		* set to missing after each step so that if question is answered in a later wave, we replace the missing with data; 
			finmove = s_finmove98; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = s_finmove00; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = s_finmove02; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = s_finmove04; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = s_finmove06; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = s_finmove08; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = s_finmove10; if finmove > 6 then finmove = .; 

			if finmove = . then finmove = p_finmove02; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = p_finmove04; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = p_finmove06; if finmove > 6 then finmove = .; 
			if finmove = . then finmove = p_finmove08; if finmove > 6 then finmove = .; 
			
			if finmove = 5 then finmove = 0; * no recoded as 0 rather than 5; 
		

	* recieve finacial help from relatives; 
		* set to missing after each step so that if question is answered in a later wave, we replace the missing with data; 
			finhelp = s_finhelp98; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = s_finhelp00; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = s_finhelp02; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = s_finhelp04; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = s_finhelp06; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = s_finhelp08; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = s_finhelp10; if finhelp > 6 then finhelp = .; 
					 
			if finhelp = . then finhelp = p_finhelp02; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = p_finhelp04; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = p_finhelp06; if finhelp > 6 then finhelp = .; 
			if finhelp = . then finhelp = p_finhelp08; if finhelp > 6 then finhelp = .; 

			if finhelp = 5 then finhelp = 0; * no recoded as 0 rather than 5; 
		
	* father lose job; 
		* set to missing after each step so that if question is answered in a later wave, we replace the missing with data; 
			losejob =  s_losejob98; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = s_losejob00; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = s_losejob02; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = s_losejob04; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = s_losejob06; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = s_losejob08; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = s_losejob10; if losejob > 7 then losejob = .; 

			if losejob = . then losejob = p_losejob98; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = p_losejob00; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = p_losejob02; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = p_losejob04; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = p_losejob06; if losejob > 7 then losejob = .; 
			if losejob = . then losejob = p_losejob08; if losejob > 7 then losejob = .; 

			* categorical variable for factor analysis; 
				if losejob = 6 then f_work = 0; * father never worked / always disabled; 
				if losejob = 1 then f_work = 1; * father lost job for several months; 
				if losejob = 5 then f_work = 2; * father not unemployed for several months;  
				if losejob = 7 then f_work = .; * people who never lived with their father / father dead.  	We set this to missing for the factor analysis so we can impute
																											a scale score for people who did not grow up with their father. 
																											We create an absent father indicator below.; 
			* create indicator for not growing up with father; 
				f_absent = (losejob = 7); if losejob = . then f_absent = .;

	* mother work; 
		* set to missing after each step so that if question is answered in a later wave, we replace the missing with data; 
			momwork =  s_momwork06; if momwork > 7 then momwork = .; 
			if momwork = . then momwork = s_momwork08; if momwork > 7 then momwork = .; 
			if momwork = . then momwork = s_momwork10; if momwork > 7 then momwork = .; 

			if momwork = . then momwork = p_momwork06; if momwork > 7 then momwork = .; 
			if momwork = . then momwork = p_momwork08; if momwork > 7 then momwork = .; 

			* indicator for no mom; 
				nomom = (momwork = 7); 
				if momwork = . then nomom = .;

			* categorical variable for factor analysis; 
				if momwork = 1 then m_work = 0; * mother worked all the time;
				if momwork = 3 then m_work = 1; * mother worked some of the time;
				if momwork = 5 then m_work = 2; * mother did not work;
				if momwork = 7 then m_work = .; * never lived with their mother / mother dead.  This is set to missing for the same reason as the f_work variable; 
				

	* live with grandparents; 
		* set to missing after each step so that if question is answered in a later wave, we replace the missing with data; 
			gramps = s_gramps96; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = s_gramps00; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = s_gramps02; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = s_gramps04; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = s_gramps06; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = s_gramps08; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = s_gramps10; if gramps > 7 then gramps = .; 

			if gramps = . then gramps = p_gramps00; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = p_gramps02; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = p_gramps04; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = p_gramps06; if gramps > 7 then gramps = .; 
			if gramps = . then gramps = p_gramps08; if gramps > 7 then gramps = .; 

			if gramps = 5 then gramps = 0; * recode no as 0 rather than 5; 


	* subset data for exploratory analysis to make sure we're not picking up missing data patterns; 
			if m_atten ne . then want_these = 1; 
			
	*Mplus can only take one id variable;
		HHIDPN2=1000*HHID + PN;
	 
	run;

/* 1996 experimental module; data includes: 
		1. measures of childhood social capital that reflects family structure 
		2. measures of childhood financial capital */ 

	* set missing data to missing; 
		data analysis_vars2; 
			set analysis_vars; 

			if e5655 > 7 then e5655 = .; 		* self-reported SES; 
			if e5657_1 > 7 then e5657_1 = .; 	* lose job; 
			if e5657_2 > 7 then e5657_2 = .; 	* lose business; 
			if e5657_3 > 7 then e5657_3 = . ; 	* bankupcy; 
			if e5657_4 > 7 then e5657_4 = .; 	* finmove; 
			if e5657_5 > 7 then e5657_5 = .; 	* finhelp; 

		/* I don't set the family structure items to missing because I use the missing data -- see Appendix Figure A2 for details */ 
		run; 

	* data for Appendix Figure A2 ;
	* cross tabs to see if family structure is mutually exclusive; 
		proc freq data = analysis_vars2; 
			table e5658*e5660 / missing; 
			title "both parents and step parents"; 
		run; /* mutually exclusive, only answered this if did not live with both parents */ 
		proc freq data = analysis_vars2; 
			table e5658*e5659 / missing; 
			title "both parents and why not both parents"; 
		run; /* mutually exclusive, obviously */ 
		proc freq data = analysis_vars2; 
			table e5659*e5660 / missing; 
			title "why not both parents and step parents"; 
		run; /* mutually exclusive, only answered lived with stepparents if parents divorced / separated */ 
		proc freq data = analysis_vars2; 
			table e5658*s_gramps96 / missing; 
			title "live with both parents and live with grand parents"; 
		run; 

	* cross tabs to see if financial capital is mutually exclusive -- not in appendix; 
		proc freq data = analysis_vars2; 
			table e5657_2*e5657_3;
			title "father lose business and father declare bankrupcy";
		run; 

	data analysis_vars3;
		set analysis_vars2;

		* social capital -- creating "fam_str" (short for family structure).  More details in Appendix Figure A2, letters refer to
			terminal response options detailed in figure; 
			fam_str = .; 
			parentdied = 0; 
			if e5658 = 1 then fam_str = 0; 		*a;
			if e5658 in (8,9) then fam_str = 3; *b; 

			if e5659 = 1 then fam_str = 3; 		*c: parent died;
			if e5659 = 1 then parentdied = 1; 	*c: parent died;
			if e5659 = 7 then fam_str = 2; 		*d;
			if e5659 in (8,9) then fam_str = 3; *e; 
		
			if e5660 = 1 then fam_str = 1; 		*f; 
			if e5660 = 5 then fam_str = 2; 		*g; 
			if e5659 = 2 & e5660 = . then fam_str = 3; 

		* financial capital -- recode variables for factor analysis.  I create new variables with _n for variables that are 
			in both the 1996 experimental module and the core questionnaire. I wanted to differentiate between 1996 and the core
			because the response options were different in 1996 vs. the core questionnaire, and because I wanted to see how peole changed
			their responses over time;

			* self-reported SES - expanded response options available in experimental module; 
				famses_n = e5655; 	

			* father lose job & not able to find one for several months; 
				f_work_n = f_work; 
				if e5657_1 = 1 then f_work_n = 1;
				if e5657_1 = 5 then f_work_n = 2; 

			* lose business -- only included in experimental module;
				lose_bus = .; 
				if e5657_2 = 1 then lose_bus = 1;
				if e5657_2 = 5 then lose_bus = 0;

			* declare bankrupcy -- only included in experimental module;
				bankrup = .; 
				if e5657_3 = 1 then bankrup = 1;
				if e5657_3 = 5 then bankrup = 0;

			* move for financial reasons; 
				finmove_n = finmove; 
				if e5657_3 = 1 then finmove_n = 1; 
				if e5657_3 = 5 then finmove_n = 0; 
			
			* finhelp from relatives;
				finhelp_n = finhelp;  
				if e5657_4 = 1 then finhelp_n = 1; 
				if e5657_4 = 5 then finhelp_n = 0;

	run;  
	* cross tabs to see how the numbers are changing; 
		proc freq data = analysis_vars3; 
			table famses*famses_n / missing;
			title "cross tabs to see how the numbers are changing";
		run; 
		proc freq data = analysis_vars3; 
			table f_work*f_work_n / missing;
			title "cross tabs to see how the numbers are changing";
		run; 
		proc freq data = analysis_vars3; 
			table finmove*finmove_n / missing;
			title "cross tabs to see how the numbers are changing";
		run; 
		proc freq data = analysis_vars3; 
			table finhelp*finhelp_n / missing;
			title "cross tabs to see how the numbers are changing";
		run;  
/* 	ok! quite a few peole change their responses over time.  I wrote in the manuscript that I'd use the first reported response option, so 
	I'm going to write over the response recorded later with the responses recorded in 1996. I also decided to do this because I don't 
	know which response option to believe and I think it's best to be systematic. */   

	* recode new variables so they have the old varible name for consistency with code in other files; 
		data analysis_vars4; 
			set analysis_vars3;

			f_work = f_work_n; 
			finmove = finmove_n; 
			finhelp = finhelp_n; 
		run; 


* How many people with data set to missing for methods section of the paper; 
	proc freq data = analysis_vars4;
		table 	famses famses2 /* 276, 1.03% of respondents who said their SES varied recoded to average -- used in methods section*/
				momwork m_work /* 534, 2.58% with no mom*/ 
				losejob f_work /* 2,459, 8.98% with no data */ 	
		;
		title "Number of observations set to missing for methods section";
	run; 

* I used this code to make sure everything was coded correctly, it also has the numbers presented in Figures 2 and 3; 
proc freq data = analysis_vars4; 
	table 	/* social capital */ 
			m_effort 
			m_atten
			m_life   
			fam_str
			gramps
			nomom
			f_absent 
			
			/* financial capital */ 
			famses_n
			famses
			focc_cat
			f_work							
			finhelp
			finmove		
			bankrup
			lose_bus
			
			m_work
			;
	title "Numbers for Figure 2"; 
run; 


/* create premanent data set */
data cses.for_mplus_rnr;
	set analysis_vars4; 

	keep 	hhidpn2 
			hhid pn 

			/* social capital */
			gramps				
			fam_str
			nomom	
			m_life   
			m_effort 
			m_atten
			f_absent /* absent father indicator */ 

			/* financial capital  */
			focc_cat
			famses_n
			famses
			famses2 /* need this to create Luo measure */
			finmove				
			finhelp
			f_work		
			m_work
			lose_bus
			bankrup
			;
run; 




/* Code for Appendix 1 - form dataset called "merged" */ 

	proc freq data = merged;
		table 	e5655 		/* how well off family */ 
				e5657_1 	/* father lose job */ 
				e5657_2		/* father / family lose business */ 
				e5657_3		/* father / family declare bankrupcy */		
				e5657_4		/* move for financial reasons */ 
				e5657_5		/* recieved financial help from relatives */ 

			/* Social capital questions */ 
				e5658 		/* live with both parents */
				e5659 		/* why  not both parents  */ 
				e5660 		/* live with step parents */
				e5661;  
		title "1996 core";
	run; 
	proc freq data = merged;
		table	f997hm 		/* father's occupation */ 
				f993 		/* fam ses */
				F994 		/* fin move */ 
				F995 		/* fin help */
				F996; 		/* father lose job */ 
		title "1998 core";
	run; 
	proc freq data = merged;
		table	q997M 		/* father's occupation */
				q996 		/* father lose job */;
		title "1998 exit";
	run; 
	proc freq data = merged;
		table	G1084M 		/* father's occupation */ 
				G1080 		/* fam ses */ 
				G1081 		/* fin move */ 
				G1082 		/* fin help */ 
				G1083 		/* father lose job */ 
				G1085 		/* live with grandparents */ ;
		title "2000 core";
	run;
	proc freq data = merged;
		table	R1069M 		/* father's occupation */ 
				R1068 		/* father lose job */ 
				R1070 	/* live with grandparents */;
		title "2000 exit";
	run; 
	proc freq data = merged;
		table	HB024M 		/* father's occupation */ 
				Hb020 		/* fam ses */ 
				HB021 		/* fin move */ 
				HB022 		/* fin help */
				HB023	 	/* father lose job */ 
				HB025 		/* live with grand parent */ ;
		title "2002 core";
	run;
	proc freq data = merged;
		table	SB020 		/* fam ses */ 
				SB021	 	/* fin move */
				SB022	 	/* fin help */ 
				SB023	 	/* father lose job */ 
				SB025	 	/* live with grandparents */;
		title "2002 exit";
	run;
	proc freq data = merged;
		table	JB024M	 	/* father's occupation */ 
				JB020 		/* fam ses */ 
				JB021 		/* fin move */ 
				JB022 		/* fin help */ 
				JB023 		/* father lose job */ 
				JB025 		/* live with grandparents */ ;
		title "2004 core";
	run;
	proc freq data = merged;
		table	TB020 		/* fam ses */ 
				TB021 		/* fin move */ 
				TB022 		/* fin help */ 
				TB023 		/* father lose job */ 
				TB025 		/* live with grandparents */ ;
		title "2004 exit";
	run;
	proc freq data = merged;
		table	KB024M 		/* father's occupation */
				KB020 		/* fam ses */ 
				KB021 		/* fin move */ 
				KB022 		/* fin help */ 
				KB023 		/* father lose job */ 
				KB025 		/* live with grandparents */  
				KB088 		/* mother work during childhood */;
		title "2006 core";
	run;
	proc freq data = merged;
		table	UB024M	 	/* father's occupation */
				UB020 		/* fam ses */ 
				UB021 		/* fin move */ 
				UB022 		/* fin help */ 
				UB023 		/* father lose job */ 
				UB025 		/* live with grandparents */ 
				UB088 		/* mother work during childhood */;
		title "2006 exit";
	run;
	proc freq data = merged;
		table	LB020 		/* fam ses */ 
				LB021 		/* fin move */ 
				LB022 		/* fin help */ 
				LB023 		/* father lose job */ 
				LB025 		/* live with grandparents */ 
				LB088 		/* mother work during childhood */;
		title "2008 core";
	run;
	proc freq data = merged;
		table	LLB037H		/* amt time / attention from mother */
				LLB037I 	/* effort from mother */ 
				LLB037J		/* amt mother teach about life */ ;
		title "2008 leave behind";
	run;
	proc freq data = merged;
		table	VB024M 		/* father's occupation */
				VB020 		/* fam ses */ 
				VB021 		/* fin move */ 
				VB022 		/* fin help */ 
				VB023 		/* father lose job */ 
				VB025 		/* live with grandparents */ 
				VB088 		/* mother work during childhood */;
		title "2008 exit";
	run;
	proc freq data = merged;
		table	MB024M 		/* father's occupation */
				MB020 		/* fam ses */ 
				MB021 		/* fin move */ 
				MB022 		/* fin help */ 
				MB023 		/* father lose job */ 
				MB025 		/* live with grandparents */ 
				MB088 		/* mother work during childhood */;
		title "2010 core";
	run;
