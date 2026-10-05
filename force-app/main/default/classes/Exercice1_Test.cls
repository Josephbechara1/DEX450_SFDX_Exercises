/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Exercice1_Test {

    @isTest
    static void myUnitTest() {
        // TO DO: implement unit test
        Map<String,Integer> actual  = Exercice1.countOccurrences(new List <String>{'a','b','c','d'});
        Map <String,Integer> expected = new Map < String,Integer>{
            'a'=>1,
            'b'=>1,
            'c'=>1,
            'd'=>1
    
        };
        Assert.areEqual(expected,actual,'Not Equal');
        Assert.areEqual(1,actual.get('a'));
    }

}