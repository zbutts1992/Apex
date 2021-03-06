public with sharing class nmiCallout {

    public String name {get; set;}
    public String amount {get; set;}
    public String success {get; set;}
    public String myDate {get; set;}
    public String eachTrans {get; set;}
    public String email {get; set;}
    public String description {get; set;}
    public String info {get; set;}
    
public nmiCallout() {
    parseResponse(createReq());
} 

public HttpResponse createReq() {
    Http http;
    HttpRequest req;
    HTTPResponse res;
    this.name = null;
    this.amount = null;
    this.success = null;
    this.myDate = null;
    this.eachTrans = null;
    this.email = System.currentPageReference().getParameters().get('email'); //Record email is passed in url for controller's page
    
    req = new HttpRequest();
    req.setEndpoint('https://secure.nmi.com/api/query.php?username=usernameHere&password=passwordHere&otherParams=params');
    req.setMethod('GET');
      
    http = new Http();
    res = http.send(req);
    
    return res;
    }
   
public void parseResponse(HttpResponse xml) {
    date transDate;
    eachTrans = 'All transactions for email on account: ';
    List<Dom.XmlNode> transList;
    List<Dom.XmlNode> actionList;
    String year;
    String month;
    String day;
    String fullDate;
    
    Dom.Document doc = new Dom.Document();
    doc.load(xml.getBody());
    
    Dom.XmlNode nodes = doc.getRootElement();   
    List<Dom.XmlNode> rootList = nodes.getChildren();
    
    // Loops through all main root nodes
    for (Dom.XmlNode i: rootList) 
    {
        transList = i.getChildren();
    // Loops through root nodes children    
            for (Dom.XmlNode j : transList)
            {
                if (j.getName() =='order_description')
                    description = 'Latest plan purchased: ' + j.getText();
                if (j.getName() =='first_name')
                    name = j.getText();
                if (j.getName() =='last_name')
                    name += ' ' + j.getText() + '<br>';
                if (j.getName() =='cc_number') //Last four digits.
                	info = j.getText();
                if (j.getName() == 'action' )
                    {
                    actionList = j.getChildren();        
                               
                    if (!(actionList.get(3).getText() == 'sale'))
                    continue;                   
                    else
                    {
                          fullDate = actionList.get(5).getText();
                          year = fullDate.substring(0,4);                     
                          month = fullDate.substring(4,6) + '/';
                          day = fullDate.substring(6,8) + '/';
                          myDate = string.Valueof(date.parse(month + day+ year));
                          
                    // Loop through action nodes children
                        for (Dom.XmlNode k : actionList)
                        {
                            if (k.getName() == 'amount')
                                amount = k.getText();
                            if (k.getName() == 'success')
                                if (k.getText() == '0')
                                {
                                    eachTrans += '<br>Payment FAILED on ' + myDate + ' for : ' + amount + ' with card ending in: ' + info;
                                }
                                else if (k.getText() == '1')
                                {
                                    eachTrans += '<br>Payment successful on ' + myDate + ' for : ' + amount + ' with card ending in: ' + info;
                                }
                        }
                    }
                }
            }
        }
    }        
}
