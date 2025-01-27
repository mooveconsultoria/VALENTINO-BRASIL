#Include "rwmake.ch"
#Include "TbiConn.ch"

User Function VALEN001()
Local _aArea        := GetArea()
Local aParamBox     := {}
Local _cLinha       := "Tipo de Registro;Filial;Emiss�o;Forma de Pagamento;Valor"+Chr(13)+Chr(10)
Local _cDirUsr      
Local cDirUsr       := GetTempPath()
Private _cErro      := ""
Private cArquivo 

If Select("SX2") = 0
    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"
Endif

_cDirUsr      := GetNewPar("ZZ_LOCJSON","\json\")

aAdd(aParamBox,{1,"Filial de :"  ,Space(TamSX3("F2_FILIAL")[1]),"","","","",40,.F.}) 
aAdd(aParamBox,{1,"Filial ate:"  ,Space(TamSX3("F2_FILIAL")[1]),"","","","",40,.F.}) 
aAdd(aParamBox,{1,"Nota Fiscal de:"  ,Space(TamSX3("F2_DOC")[1]),"","","","",50,.F.}) 
aAdd(aParamBox,{1,"Nota Fiscal ate:"  ,Space(TamSX3("F2_DOC")[1]),"","","","",50,.F.}) 
aAdd(aParamBox,{1,"Serie de:"  ,Space(TamSX3("F2_SERIE")[1]),"","","","",30,.F.}) 
aAdd(aParamBox,{1,"Serie ate:"  ,Space(TamSX3("F2_SERIE")[1]),"","","","",30,.F.}) 
aAdd(aParamBox,{3,"Tipo de Registro:",1,{"1-Vendas","2-Transferencias","3-Devol/Retornos","4-Canc Vendas","5-Canc Transf","6-Canc Dev/Ret","7-Todos"},50,"",.F.})
aAdd(aParamBox,{3,"Relatorios de Conferencia ?",1,{"Nao","Sim"},50,"",.F.})

If ParamBox(aParamBox, "Informe os par�metros")

    BeginSql Alias "SQL_SF3"
                   
        SELECT *
        FROM
            %table:SF3% SF3 
        WHERE
            F3_FILIAL BETWEEN %Exp:Mv_Par01% AND %Exp:Mv_Par02% AND
            F3_NFISCAL BETWEEN %Exp:Mv_Par03% AND %Exp:Mv_Par04% AND
            F3_SERIE BETWEEN %Exp:Mv_Par05% AND %Exp:Mv_Par06% AND
            SF3.%notDel%

    EndSql

    _cQuery := GetLastQuery()[2]

    DbSelectArea("SQL_SF3")
    DbGoTop()

    Do While !Eof()

        If (Mv_Par07 = 1 .Or. Mv_Par07 = 4) .And. !Rtrim(SQL_SF3->F3_CFO) $ GetNewPar("ZZ_CFOPV","5102")
            Dbskip()
            Loop 
        ElseIf (Mv_Par07 = 2 .Or. Mv_Par07 = 5) .And. !Rtrim(SQL_SF3->F3_CFO) $ GetNewPar("ZZ_CFOPT","5152")
            Dbskip()
            Loop 
        ElseIf (Mv_Par07 = 3 .Or. Mv_Par07 = 6) .And. !Rtrim(SQL_SF3->F3_CFO) $ GetNewPar("ZZ_CFOPD","1202")
            Dbskip()
            Loop 
        Endif

        If Rtrim(SQL_SF3->F3_CFO) $ GetNewPar("ZZ_CFOPV","5102")

            If !U_GeraJson(If(Empty(SQL_SF3->F3_DTCANC),"1","4"),SQL_SF3->(F3_FILIAL+F3_NFISCAL+F3_SERIE),If(Empty(SQL_SF3->F3_DTCANC),"N","C"),"2")
                Alert(_cErro)
            Endif

        ElseIf Rtrim(SQL_SF3->F3_CFO) $ GetNewPar("ZZ_CFOPT","5152")

            If !U_GeraJson(If(Empty(SQL_SF3->F3_DTCANC),"2","5"),SQL_SF3->(F3_FILIAL+F3_NFISCAL+F3_SERIE),If(Empty(SQL_SF3->F3_DTCANC),"N","C"),"2")
                Alert(_cErro)
            Endif

        ElseIf Rtrim(SQL_SF3->F3_CFO) $ GetNewPar("ZZ_CFOPD","1202")

            If !U_GeraJson(If(Empty(SQL_SF3->F3_DTCANC),"3","6"),SQL_SF3->(F3_FILIAL+F3_NFISCAL+F3_SERIE),If(Empty(SQL_SF3->F3_DTCANC),"N","C"),"2")
                Alert(_cErro)
            Endif
            
        Endif

        If Mv_Par08 = 2

            _cLinha += RetJson(_cDirUsr+cArquivo)

        Endif

        DbSelectArea("SQL_SF3")
        DbSkip()

    Enddo

Endif

If Mv_Par08 = 2

    cArqCsv := "Rel"+Dtos(MsDate())+".CSV"
    MemoWrite(cArqCsv,_cLinha)
    CpyS2T(cArqCsv, cDirUsr)
    ShellExecute("open",cDirUsr+cArqCsv,"","",1)

Endif

RestArea(_aArea)
Return .T.

Static Function RetJson(cFile)
Local _cRet := ""
Local _n

cJsonStr := readfile(cFile)

oJson := JSonObject():New()
cErr  := oJSon:fromJson(cJsonStr)

If !empty(cErr)
  MsgStop(cErr,"JSON PARSE ERROR")
  Return
Endif

For _n := 1 to Len(oJson:GetJSonObject('PaymentMethods'))

    _cRet += oJson:GetJSonObject('InvoiceType')+";"
    _cRet += oJson:GetJSonObject('Branch')+";"
    _cRet += oJson:GetJSonObject('InvoiceDateOf')+";"
    _cRet += oJson:GetJSonObject('PaymentMethods')[_n]+";"
    _cRet += Str(oJson:GetJSonObject('PaymentTotal')[_n],12,2)+Chr(13)+Chr(10)

Next

FreeObj(oJson)

Return _cRet

STATIC Function ReadFile(cFile)
Local cBuffer := ''
Local nH , nTam
nH := Fopen(cFile)
IF nH != -1
    nTam := fSeek(nH,0,2)
    fSeek(nH,0)
    cBuffer := space(nTam)
    fRead(nH,@cBuffer,nTam)
    fClose(nH)
Else
    MsgStop("Falha na abertura do arquivo ["+cFile+"]","FERROR "+cValToChar(Ferror()))
Endif

Return cBuffer
