import pandas as pd
import numpy as np
import math


def performance(TP, TN, FP, FN, BETA):
    
    N = TP+TN+FP+FN
    
    Sensitivity=(TP/(TP+FN))*100

    Specificity=(1-FP/(TN+FP))*100

    Accuracy=((TP+TN)/(TP+TN+FP+FN))*100

    PPV= (TP/(TP+FP))*100 

    NPV= (TN/(TN+FN))*100 
    
    F_BETA_score = (1+(BETA**2)) * (PPV*Sensitivity)/(((BETA**2)*PPV)+Sensitivity)
    
    result = {
        'Sensitivity': [Sensitivity],
        'Specificity': [Specificity],
        'Accuracy':[Accuracy],
        'PPV':[PPV],
        'NPV':[NPV],
        f'F_{BETA} score':[F_BETA_score]        
    }
    
    result_2 = pd.DataFrame(result)
    
    return result_2