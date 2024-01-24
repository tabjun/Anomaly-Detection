import numpy as np
import pandas as pd

def ewma(data, initial, gamma, k):
    
    # sort by update_time
    data = data.sort_values(by='update_time')
    
    # ewma 계산
    ewma = np.empty(len(data)) # data의 length만큼 데이터 생성
    ewma[0] = initial # 초기값 설정
    for i in range(1, len(data)):
        ewma[i] = gamma * data['heart_rate'].iloc[i] + (1-gamma)*ewma[i-1]
        
    # 신뢰구간 계산
    stdd = data['heart_rate'].std()
    
    lcl = ewma - k * np.sqrt(gamma / (2-gamma)) * stdd
    ucl = ewma + k * np.sqrt(gamma / (2-gamma)) * stdd
    
    # outlier labeling
    outlier_yn = np.where((ewma < lcl) | (ewma > ucl), 'Y', 'N')
    
    # 테이블로 만들기
    ewma_out = pd.DataFrame({'update_time': data['update_time'],
                             'ewma': ewma,
                             'lcl': lcl,
                             'ucl': ucl,
                             'outlier_yn': outlier_yn})
    
    return ewma_out