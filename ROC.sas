data roc;
   input alb tp totscore popind @@;
   totscore = 10 - totscore;
   datalines;
3.0 5.8 10 0   3.2 6.3  5 1   3.9 6.8  3 1   2.8 4.8  6 0   
3.2 5.8  3 1   0.9 4.0  5 0   2.5 5.7  8 0   1.6 5.6  5 1   
3.8 5.7  5 1   3.7 6.7  6 1   3.2 5.4  4 1   3.8 6.6  6 1   
4.1 6.6  5 1   3.6 5.7  5 1   4.3 7.0  4 1   3.6 6.7  4 0   
2.3 4.4  6 1   4.2 7.6  4 0   4.0 6.6  6 0   3.5 5.8  6 1   
3.8 6.8  7 1   3.0 4.7  8 0   4.5 7.4  5 1   3.7 7.4  5 1   
3.1 6.6  6 1   4.1 8.2  6 1   4.3 7.0  5 1   4.3 6.5  4 1   
3.2 5.1  5 1   2.6 4.7  6 1   3.3 6.8  6 0   1.7 4.0  7 0   
3.7 6.1  5 1   3.3 6.3  7 1   4.2 7.7  6 1   3.5 6.2  5 1   
2.9 5.7  9 0   2.1 4.8  7 1   2.8 6.2  8 0   4.0 7.0  7 1   
3.3 5.7  6 1   3.7 6.9  5 1   3.6 6.6  5 1   
;



proc logistic data=roc plots=roc(id=prob);
   model popind(event='1') = alb tp totscore / nofit;
   roc 'first1' alb ;
   roc 'first3' alb tp totscore;
   roccontrast reference('first1') / estimate e;
run;


%include "D:\04 Thinking\38 ROC NRI  IDI\add_predictive.sas";
%include "D:\04 Thinking\38 ROC NRI  IDI\hoslem.sas"; 

data roc;
 set roc;
 cnt+1;
run;


proc logistic data=roc plots=roc;
   model popind(event='1') = alb ;
   output out=m1 pred=p1;
run;

proc logistic data=roc plots=roc;
   model popind(event='1') = alb tp totscore;
   output out=m2 pred=p2;
run;


proc sql;
	create table m as select *
	from m1 as a left join m2 as b on a.cnt=b.cnt;
quit;

%add_predictive(data=m, y=popind, p_old=p1 , p_new=p2, nripoints=%str(),hoslemgrp=10)


