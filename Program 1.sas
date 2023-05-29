*Analysis of BRFSS data

Outcome variable:CVDSTRK3 ((Ever told) you had a stroke?)

Explanatory variable of interest: AVEDRNK3, EMPLOY1, X_AGEG5YR, INCOME3, DIABETE4, CVDINFR4, CVDCRHD4, CVDSTRK3, SEXVAR, EDUCA, X_RACE, BPHIGH6

Numeric variable:AVEDRNK3 (On average, how many average drinks you had in last 30 days?)

Categorical variables (>2 levels):X_AGEG5YR(Age groups: 45-54 yrs, 55-64, 65yrs or older) SEXVAR (Sex) SMOKDAY2 (Do you now smoke
 cigarettes every day, some days, or not at all?) EMPLOY1(Employment status) X_RACE(Different races) INCOME3 (Income levels) EDUCA( Education status), DIABETE4(Yes, no and borderline), BPHIGH6 (Hypertension present and absent), CVDINFR4 (Myocardial Infacrtion) , CVDCRHD4 (Chronic Heart Disease)
*/
;

LIBNAME a "/home/u60771138/BRFSS";

OPTIONS FMTSEARCH=(a.p25format);

proc import datafile = '/home/u60771138/BRFSS/brfss2021new.csv'
 out = work.brfss
 dbms = CSV
 ;
run;

*/we use "data" , "set" and "keep" functions to generate the dataset
*/
;
DATA a2;
set brfss;
keep X_SMOKER3 AVEDRNK3 EMPLOY1 X_AGEG5YR INCOME3 DIABETE4 CVDINFR4 CVDCRHD4 CVDSTRK3 SEXVAR EDUCA X_RACE BPHIGH6;
RUN;


DATA a3;
SET a2;
if BPHIGH6 in (3,4,7,9) then delete;
if DIABETE4 in (2,7,9) then delete;
if CVDINFR4 in (3,4,7,9) then delete;
if CVDCRHD4 in (3,4,7,9) then delete;
if CVDSTRK3 in (3,4,7,9) then delete;
if X_AGEG5YR =1 then AGEGROUP = 1;
if X_AGEG5YR in (2,3,4,5) then AGEGROUP = 2;
if X_AGEG5YR in (6,7,8,9) then AGEGROUP = 3;
if X_AGEG5YR in (10,11,12,13) then AGEGROUP = 4;
if X_AGEG5YR = 14 then delete;
if X_RACE in (5,6,7,9) then delete;
if X_SMOKER3 = 9 then delete;
if EDUCA=9 THEN DELETE;
if AVEDRNK3 in (77,88,99) then delete;
if income3 in (77,99) then delete;
if employ1=9 then delete;
if AVEDRNK3 =< 5 then AVEDRNK3=1;
if AVEDRNK3 >5 then AVEDRNK3=2;
run;

proc contents data= a3;
run;

*Distribution of categorical variables;

PROC FREQ DATA=a3;
   TABLES SEXVAR*CVDSTRK3 CVDCRHD4*CVDSTRK3 AVEDRNK3*CVDSTRK3 AGEGROUP*CVDSTRK3 CVDINFR4*CVDSTRK3 EMPLOY1*CVDSTRK3 X_SMOKER3*CVDSTRK3 BPHIGH6*CVDSTRK3 DIABETE4*CVDSTRK3 INCOME3*CVDSTRK3 EDUCA*CVDSTRK3 X_RACE*CVDSTRK3 / NOROW NOPERCENT CHISQ EXPECTED;
RUN;

DATA a6;
set a3;
if CVDSTRK3=2 THEN DELETE;
RUN;

PROC FREQ data=A6;
  TABLES _ALL_ / OUT=freq_table;
RUN;

*collinearity;

/* Examination of the Correlation Matrix */
proc corr data=a3;
var X_SMOKER3 AVEDRNK3 EMPLOY1 X_AGEG5YR INCOME3 DIABETE4 CVDINFR4 CVDCRHD4 CVDSTRK3 SEXVAR EDUCA X_RACE BPHIGH6;
run;


*simple logistic regression;

PROC LOGISTIC DATA = a3;
CLASS SEXVAR (REF="1")/ PARAM = REF;                 /*Yes=Male, N0=Female*/
MODEL CVDSTRK3 (EVENT="1")= SEXVAR;
RUN;

PROC LOGISTIC DATA = a3;
CLASS X_RACE (REF="1")/ PARAM = REF;                 /*1=White  2=Black  3=American Natives  4=Asian   5=Hispanic*/
MODEL CVDSTRK3 (EVENT="1")= X_RACE;
RUN;

PROC LOGISTIC DATA = a3;
CLASS AGEGROUP (REF="1")/ PARAM = REF;               /*1=18-24years  2=25-44years  3=45-64years  4=Above 65years*/ 
MODEL CVDSTRK3 (EVENT="1")= AGEGROUP;
RUN;

PROC LOGISTIC DATA = a3;
CLASS X_SMOKER3 (REF="1")/ PARAM = REF;             /*1=Every day 2=Some days 3=Not at all*/
MODEL CVDSTRK3 (EVENT="1")= X_SMOKER3;
RUN;

PROC LOGISTIC DATA = a3;
CLASS CVDCRHD4(REF="1")/ PARAM = REF;
MODEL CVDSTRK3 (EVENT="1")= CVDCRHD4;                    /*Yes=1, No=2*/
RUN;

PROC LOGISTIC DATA = a3;
CLASS DIABETE4 (REF="1")/ PARAM = REF;
MODEL CVDSTRK3 (EVENT="1")= DIABETE4;                    /*Yes=1, Borderline=2, No=3*/
RUN;


PROC LOGISTIC DATA = a3;
CLASS BPHIGH6;
MODEL CVDSTRK3 (EVENT="1")= BPHIGH6;                    /*Yes=1, No=2*/
RUN;

PROC LOGISTIC DATA = a3;
CLASS CVDINFR4;
MODEL CVDSTRK3 (EVENT="1")= AVEDRNK3;                    /*Yes=1, No=2*/
RUN;

PROC LOGISTIC DATA = a3;
CLASS INCOME3 (REF="1")/ PARAM = REF;
MODEL CVDSTRK3 (EVENT="1")= INCOME3;                     /*1=less than $10,000  2=less than $15,000  3=less than $20,000  4=less than $25,000  5=less than $35,000 6=less than $50,000 7=less than $75,000 8=less than $100,000? 9=less than one $150,000? 10=less than $200,000 11=$200,000 or more*/
RUN;

PROC LOGISTIC DATA = a3;
CLASS EDUCA (REF="1")/ PARAM = REF;
MODEL CVDSTRK3 (EVENT="1")= EDUCA;                       /*1=never attended school 2=Elementary 3=some high school 4=High School graduate 5=some college or technical school 6=college graduate*/
RUN;

PROC LOGISTIC DATA=a3;                                   /*1=Less or equal to 5   2=More than 5*/
CLASS AVEDRNK3 / CONTINUOUS;
MODEL CVDSTRK3=AVEDRNK3;
RUN;


proc format;
value AGEGROUP
1="18-24 years"
2="25 to 44 years"
3="45 to 64 years"
4="Above 65 years";
run;

proc format;
value agefmt
1="18-24 years"
2="25 to 44 years"
3="45 to 64 years"
4="Above 65 years";
run;

/* format AGEGROUP variable using the agefmt format */
data a4;
set a3;
format AGEGROUP agefmt.;
run;

*sgplot;

/* Define the graphics output device */
goptions device=png;

/* Create a vertical bar chart of age group counts */
proc sgplot data=a4;
   vbar AGEGROUP / response= ;
   xaxis discreteorder=data;
run;

data a5;
set a4;
if CVDSTRK3=2 then delete;
run;


data a4;
set a3;
if CVDSTRK3=2 THEN DELETE;
RUN;

proc format;
value SEXVAR
1="MALE"
2="FEMALE"
;
run;

proc format;
value sexfmt
1="MALE"
2="FEMALE"
;
run;

/* format SEXVAR variable using the sexfmt format */
data a5;
set a4;
format SEXVAR sexfmt.;
run;


title "Sex Variable Bar Chart - Using PROC SGPLOT";
proc sgplot data=a5;
vbar SEXVAR;
run;

/* format AGEGROUP variable using the agefmt format */

proc format;
value AGEGROUP
1="18-24 years"
2="25 to 44 years"
3="45 to 64 years"
4="Above 65 years";
run;

proc format;
value agefmt
1="18-24 years"
2="25 to 44 years"
3="45 to 64 years"
4="Above 65 years";
run;

/* format AGEGROUP variable using the agefmt format */
data a5;
set a4;
format AGEGROUP agefmt.;
run;

*sgplot;

title "Agegroup Variable Bar Chart - Using PROC SGPLOT";
proc sgplot data=a5;
vbar AGEGROUP;
run;


*multinomial logistic regression model selection;

PROC LOGISTIC DATA = a3;
 CLASS CVDCRHD4 (REF= "1") AGEGROUP (REF= "1") X_SMOKER3 (REF="1") INCOME3 (REF="1") BPHIGH6 (REF= "1") CVDINFR4(REF="1") DIABETE4 (REF="1") EDUCA(REF="1") AVEDRNK3/ PARAM= REF;
 MODEL CVDSTRK3 (EVENT = "1") = CVDCRHD4 AGEGROUP X_SMOKER3 CVDINFR4 INCOME3 AVEDRNK3 CVDINFR4 BPHIGH6 DIABETE4/SELECTION=BACKWARD INCLUDE=1;
RUN;

* evaluate the FINAL MODEL;
PROC LOGISTIC DATA = a3 PLOTS = (ROC INFLUENCE DFBETAS);
 CLASS CVDINFR4 (REF="1") AGEGROUP (REF= "1") X_SMOKER3 (REF="1") CVDCRHD4 (REF="1") DIABETE4 (REF="1") INCOME3 (REF="1")/ PARAM= REF;
 MODEL CVDSTRK3 (EVENT = "1") = CVDINFR4 AGEGROUP X_SMOKER3 CVDCRHD4 DIABETE4 INCOME3 / RSQUARE LACKFIT;
RUN;

