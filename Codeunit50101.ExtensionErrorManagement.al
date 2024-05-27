codeunit 50101 ExtensionErrorManagement
{


    procedure FixPostCode(var ErrorInfo: ErrorInfo)
    var
        Cust: Record Customer;
    begin
        if Cust.Get(ErrorInfo.RecordId) then begin
            Cust."Post Code" := GetPostCode(Cust);
            Cust.Modify();
        end;
    end;

    procedure ShowPostCodes(var ErrorInfo: ErrorInfo)
    var
        Cust: Record Customer;
        PostCode: Record "Post Code";
        PagePostCodes: Page "Post Codes";
    begin
        if Cust.Get(ErrorInfo.RecordId) then begin
            PostCode.SetRange(City, Cust.City);
            PagePostCodes.SetTableView(PostCode);
            PagePostCodes.LookupMode := true;
            if PagePostCodes.RunModal() = Action::LookupOK then begin
                PagePostCodes.GetRecord(PostCode);
                Cust."Post Code" := PostCode.Code;
                Cust.Modify();
            end;
        end;
    end;

    procedure GetPostCode(var customer: Record Customer) returnval: Code[20]
    var
        pcode: Record "Post Code";
    begin
        returnval := '';
        pcode.SetRange("Country/Region Code", customer."Country/Region Code");
        pcode.SetRange(County, customer.County);
        pcode.SetRange(City, customer.City);
        if pcode.FindFirst() then
            returnval := pcode.Code;
    end;
}