public with sharing class GetGovernotLimits {
    public GetGovernotLimits() {
        
        public class LimitsResult { 
            
            @InvocableVariable(label='Limit Usage')
            public Integer limitUsage;
            
            @InvocableVariable(label='Limit Value' )
            public Integer limitValue;
            public static List<LimitsResult> getLimit(List<String> limitNames) {
                @InvocableMethod('Get Governor Limits Usage ')
                List<LimitsResult> results = new List<LimitsResult>();
                
                for (String limitName : limitNames) {
                    
                    LimitsResult result = new LimitsResult();
                    
                    switch on limitName.toUpperCase() {
                        when 'QUERYROWS' {
                            result.limitUsage = Limits.getQueryRows();
                            result.limitValue = Limits.getLimitQueryRows();
                       
                       
                        }
                    }
                    
                }
            }
        }
    }
}