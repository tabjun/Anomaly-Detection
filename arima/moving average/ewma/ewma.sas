libname HR "C:\Users\rnjst\OneDrive - 계명대학교\2023 PROJECT\지역혁신중심 대학연구활동(대학-기업) 지원사업 공고\SAS data";
proc sort data=HR.MK_check; by update_time; run;
data MK_raw; set HR.MK_check; run;
proc sort data=MK_raw; by update_time; run;



/* --------------------------MACRO---------------------------- */

%MACRO EWMA (data, initial, gamma, k, outdata );
data ECI_DATA; set &data; run;
proc sort data=ECI_DATA; by update_time; run;

/* ------ gamma = 0.94 , k = 3 ------ * /
/* 지수가중이동평균 EWMA 산출 */
data CAL_EWMA;
 set ECI_DATA;
 	retain EWMA &initial;
		EWMA_TMP = EWMA; *전 시점의 EWMA 임시변수에 저장;
 		EWMA = &gamma*heart_rate+(1-&gamma)*EWMA; *EWMA 산출;
 * drop EWMA_TMP;
run;

/*heartrate의 표준편차(STD) 산출*/
proc means data=CAL_EWMA noprint nway;
 	var heart_rate; 
	output out=STATS_OUT std=STD;
run;

/*관리하한(LCL), 관리상한(UCL) 산출*/
proc sql;
 create table EWMA_CL as
 select t1.*, 
			t1.EWMA_TMP-&k*sqrt(&gamma/(2-&gamma))*t2.STD as LCL, 
			t1.EWMA_TMP+&k*sqrt(&gamma/(2-&gamma))*t2.STD as UCL
 from CAL_EWMA t1, 
		 STATS_OUT t2;
run;

/*이상치 여부 Tagging*/
data EWMA;
 set EWMA_CL;
 if EWMA < LCL or EWMA > UCL then OUTLIER_YN = 'Y';
 else OUTLIER_YN = 'N';
run;

proc freq data=EWMA;
table OUTLIER_YN;
run;

data &outdata; set EWMA;
where OUTLIER_YN = "Y"; run;

proc sort data=&outdata; by heart_rate; run;

proc sgplot data=EWMA;
	*where update_year = 2023;
	series x = update_time y = heart_rate;
	scatter x = update_time y = heart_rate / group = OUTLIER_YN;
run;

%mend;


%EWMA (MK_raw, 96, 0.95, 3, outdata_95_3 );
%EWMA (MK_raw, 96, 0.95, 5, outdata_95_3 );

%EWMA (MK_raw, 96, 0.9, 3, outdata_95_3 );
%EWMA (MK_raw, 96, 0.9, 5, outdata_95_3 );

%EWMA (MK_raw, 96, 0.5, 3, outdata_95_3 );
%EWMA (MK_raw, 96, 0.5, 5, outdata_95_3 );

%EWMA (MK_raw, 96, 0.3, 3, outdata_95_3 );
%EWMA (MK_raw, 96, 0.3, 5, outdata_95_3 );
