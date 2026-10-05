public with sharing class Exercice1 {
    public static Map <String,Integer> countOccurrences(List<String> values) {
        Map <String, Integer> result = new Map <String ,Integer>();
        for ( String  value : values ){
            if (result.containsKey(value )){
                result.put (value,result.get(value)+1);
            
            }
            else {
                result.put(value,1);
            }
        }
        
        return result ;
    }
}
