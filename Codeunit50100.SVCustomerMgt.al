codeunit 50100 SVCustomerMgt
{
    TableNo = 18;
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Post Code', false, false)]
    local procedure OnAfterValidatePostCode(CurrFieldNo: Integer; var Rec: Record Customer; var xRec: Record Customer)
    var
        PostCode: Record "Post Code";
        ZipCode: Code[10];
        InvalidPostCodeErrorInfo: ErrorInfo;
        PickZipCodeErrorInfo: ErrorInfo;
    begin
        if Rec."Post Code" = '' then begin
            InvalidPostCodeErrorInfo.Title := 'Post Code is not valid';

            InvalidPostCodeErrorInfo.Message :=
                StrSubstNo('You cannot leave post code empty');

            InvalidPostCodeErrorInfo.RecordId := Rec.RecordId;
            if CityHasUniquePostCode(Rec) then begin
                InvalidPostCodeErrorInfo.AddAction(
                    StrSubstNo('Set value to %1', GetPostCode(Rec)),
                    Codeunit::ExtensionErrorManagement,
                    'FixPostCode'
                );
                Error(InvalidPostCodeErrorInfo)
            end else begin
                InvalidPostCodeErrorInfo.AddAction(
                    StrSubstNo('Show Post Codes for %1', Rec.City),
                    Codeunit::ExtensionErrorManagement,
                    'ShowPostCodes'
                );
                Error(InvalidPostCodeErrorInfo);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'City', false, false)]
    local procedure OnAfterValidateCity(CurrFieldNo: Integer; var Rec: Record Customer; var xRec: Record Customer)
    var
        PostCode: Record "Post Code";
        ZipCode: Code[10];
        InvalidPostCodeErrorInfo: ErrorInfo;
        ShowCitiesErrorInfo: ErrorInfo;
    begin
        if Rec.City = '' then begin
            ShowCitiesErrorInfo.Message('Please select the City');

            ShowCitiesErrorInfo.AddNavigationAction(
                StrSubstNo('Show Cities')
            );
            ShowCitiesErrorInfo.PageNo(Page::"Post Codes");
            Error(ShowCitiesErrorInfo);
        end;
    end;



    local procedure CityHasUniquePostCode(var customer: Record Customer): boolean
    var
        pcode: Record "Post Code";
    begin
        pcode.SetRange("Country/Region Code", customer."Country/Region Code");
        pcode.SetRange(County, customer.County);
        pcode.SetRange(City, customer.City);
        if pCode.Count = 1 then
            exit(true)
        else
            exit(false);
    end;

    local procedure GetPostCode(var customer: Record Customer) returnval: Code[20]
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