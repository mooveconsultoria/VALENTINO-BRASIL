#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'



/*
* Funcao		:	RHFICHFU
* Autor			:	Mauricio Dizimbat - TOTVS IP
* Data			: 	07/05/2021
* Descricao		:	Relatorio Gerencial de Folha de Pagamento
*/
User Function RHFICHFU()

Private cPeriodo  := SPACE(getSx3Cache("RC_PERIODO","X3_TAMANHO"))
Private cFilDe    := SPACE(getSx3Cache("RA_FILIAL","X3_TAMANHO"))
Private cFilAte   := Padr('',getSx3Cache("RA_FILIAL","X3_TAMANHO"),'ZZ')
Private cCustoDe  := SPACE(getSx3Cache("CTT_CUSTO","X3_TAMANHO"))
Private cCustoAte := Padr('',getSx3Cache("CTT_CUSTO","X3_TAMANHO"),'ZZ')
Private cMatDe    := SPACE(getSx3Cache("RA_MAT","X3_TAMANHO"))
Private cMatAte   := Padr('',getSx3Cache("RA_MAT","X3_TAMANHO"),'ZZ')
Private cVerbas   := SPACE(1000)

if perg()
    FwMsgRun( Nil , { || montaExcel() } , 'Processando' , "Gerando Relatorio...   " )
endif

Return

//Funçao inicial se inseridos parâmetros
static function montaExcel()
    local cAlias       := ""
    local cAliasVerbas := ""
    local cDir         := nil
    local aVetor1      := {}
    local aVetor2      := {}
    
    cAlias := procDados()
    if (cAlias)->(!eof())
        aVetor1 := monta1Dados(cAlias,1)     
        MemoWrite("C:\temp\aVetor1.txt", VarInfo("aVetor1", aVetor1, , .F.))   
    endif    
    cAliasVerbas := procVerbas()
    if (cAliasVerbas)->(!eof())
        aVetor2 := monta2Dados(cAliasVerbas)      
        MemoWrite("C:\temp\aVetor2.txt", VarInfo("aVetor2", aVetor2, , .F.))   
    endif

    aVetor3 := MontaVet(aVetor1,aVetor2)

    asort(aVetor3, , ,{|x,y|x[3] > y[3]})

    if len(aVetor3) > 0
        cDir := cGetFile('*.xls|*.xls',"Selecione diretorio",,,.F.,GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY  ,.T.)
        if !empty(cDir)
            criaPlanilha(aVetor3,cDir)
        endif
    else
        msgAlert("Nao ha registros para os parâmetros selecionados. Impressao sera cancelada.")
    endif


return

//Consulta dados mediante parametros
Static Function ProcDados()
    local cQuery     := ""
    local cAlias     := getNextAlias()
    local cVerbasFil := filtroVerbas()


    cQuery += "SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RC_PD VERBA " + CRLF
    cQuery += " ,' ' AS TIPPROV , RV_DESC, RC_DATA DATAPGTO, RC_VALOR VALOR, RV_TIPOCOD " + CRLF
    cQuery += " ,  CASE WHEN RV_TIPOCOD = '1' OR RV_TIPOCOD = '3'  THEN RV_DEBITO " + CRLF
    cQuery += "         WHEN RV_TIPOCOD = '2' THEN RV_CREDITO " + CRLF
    cQuery += "         ELSE NULL END AS CONTACONTAB " + CRLF
    cQuery += " FROM " + retSqlTab("SRA") + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRC") + CRLF
    cQuery += "   ON RC_FILIAL = RA_FILIAL " + CRLF
    cQuery += "   AND RC_MAT = RA_MAT " + CRLF
    cQuery += "   AND RC_PERIODO = '" + cPeriodo + "' " + CRLF
    cQuery += "   AND SRC.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  INNER JOIN "+ retSqlTab("SRV") + CRLF
    cQuery += "   ON RV_FILIAL = '" + xfilial("SRV") +"' " + CRLF
    cQuery += "   AND RV_COD = RC_PD " + CRLF
    cQuery += cVerbasFil + CRLF
    cQuery += "   AND SRV.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' " + CRLF
    cQuery += "   AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' " + CRLF
    cQuery += "   AND RA_CC BETWEEN '"+ cCustoDe + "' AND '" + cCustoAte + "' " + CRLF
    cQuery += "   AND SRA.D_E_L_E_T_ = '' " + CRLF
    cQuery += " UNION " + CRLF
    cQuery += "SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RD_PD VERBA " + CRLF
    cQuery += " ,' ' AS TIPPROV , RV_DESC, RD_DATPGT DATAPGTO, RD_VALOR VALOR, RV_TIPOCOD " + CRLF
    cQuery += " ,  CASE WHEN RV_TIPOCOD = '1'  OR RV_TIPOCOD = '3' THEN RV_DEBITO " + CRLF
    cQuery += "         WHEN RV_TIPOCOD = '2' THEN RV_CREDITO " + CRLF
    cQuery += "         ELSE NULL END AS CONTACONTAB " + CRLF
    cQuery += " FROM " + retSqlTab("SRA") + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRD") + CRLF
    cQuery += "   ON RD_FILIAL = RA_FILIAL " + CRLF
    cQuery += "   AND RD_MAT = RA_MAT " + CRLF
    cQuery += "   AND RD_PERIODO = '" + cPeriodo + "' " + CRLF
    cQuery += "   AND SRD.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRV") + CRLF
    cQuery += "   ON RV_FILIAL = '" + xFilial("SRV") + "' " + CRLF
    cQuery += "   AND RV_COD = RD_PD " + CRLF
    cQuery += cVerbasFil + CRLF
    cQuery += "   AND SRV.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' " + CRLF
    cQuery += "   AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' " + CRLF
    cQuery += "   AND RA_CC BETWEEN '"+ cCustoDe + "' AND '" + cCustoAte + "' " + CRLF
    cQuery += "   AND SRA.D_E_L_E_T_ = '' " + CRLF

    MemoWrite("C:\Temp\qry1.txt", cQuery)

    tcQuery cQuery new alias &cAlias

return cAlias


static function procVerbas()
    local cAlias     := getNextAlias()
    local cQuery     := ""
    local cVerbasFil := filtroVerbas()


    cQuery += "SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_ZZID, RA_ZZCOST, RT_VERBA VERBA,  RT_TIPPROV TIPPROV " + CRLF
    cQuery += " , RV_DESC, RT_DATACAL DATAPGTO, RT_VALOR VALOR, RV_TIPOCOD " + CRLF
    cQuery += " ,  CASE WHEN RV_TIPOCOD = '1'  OR RV_TIPOCOD = '3' THEN RV_DEBITO " + CRLF
    cQuery += "         WHEN RV_TIPOCOD = '2' THEN RV_CREDITO " + CRLF
    cQuery += "         ELSE NULL END AS CONTACONTAB, RT_DATACAL, RT_DFERPRO " + CRLF
    cQuery += " FROM " + retSqlTab("SRA") + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRT") + CRLF
    cQuery += "   ON RT_FILIAL = RA_FILIAL " + CRLF
    cQuery += "   AND RT_MAT = RA_MAT " + CRLF
    cQuery += "   AND RT_DATACAL BETWEEN '" + dtos(monthSub(lastday(stod(cPeriodo+"01")),1)) + "' AND '" + dtos(lastday(stod(cPeriodo+"01"))) + "' " + CRLF
    cQuery += "   AND SRT.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  INNER JOIN " + retSqlTab("SRV") + CRLF
    cQuery += "   ON RV_FILIAL = '" + xFilial("SRV") + "' " + CRLF
    cQuery += "   AND RV_COD = RT_VERBA " + CRLF
    cQuery += cVerbasFil + CRLF
    cQuery += "   AND SRV.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "  WHERE RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' " + CRLF
    cQuery += "   AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' " + CRLF
    cQuery += "   AND RA_CC BETWEEN '"+ cCustoDe + "' AND '" + cCustoAte + "' " + CRLF
    cQuery += "   AND SRA.D_E_L_E_T_ = '' " + CRLF
    cQuery += "  ORDER BY RA_FILIAL, RA_MAT, RT_VERBA, RT_TIPPROV, RT_DATACAL DESC " 

    MemoWrite("C:\Temp\qry2.txt", cQuery)

    tcQuery cQuery new alias &cAlias

return cAlias    


static function filtroVerbas()
    local cRet    := ""
    local aVerbas := strTokArr(Alltrim(cVerbas),";")
    local nI      := 1

    if len(aVerbas) > 0
        cRet += " AND RV_COD IN ("
        for nI := 1 to len(aVerbas)
            cRet += "'"+aVerbas[nI]+"'"
            if nI == len(aVerbas)
                cRet+=")"
            else
                cRet+=", "
            endif
        next nI
    endif

return cRet


//Caixa de parâmetros
Static Function Perg()

local lRet       := .F.
Local cMemo		 := ""
Local cVerFerias := ""
Local cVerSalar  := ""
Local cVerCusto  := ""

DBSelectArea("RCA")
Dbsetorder(1)
If Dbseek(xFilial("RCA")+"M_REL_FERIAS")
    cVerFerias := Alltrim(RCA->RCA_CONTEU)
Endif

DBSelectArea("RCA")
Dbsetorder(1)
If Dbseek(xFilial("RCA")+"M_REL_13SAL")
    cVerSalar  := Alltrim(RCA->RCA_CONTEU)
Endif

cVerCusto := LeArqCusto()

Define MsDialog oDlg Title "Parametros" From 0,0 To 430, 320 Of oMainWnd Pixel

oSay1 := TSay():New(36,03,{||'Periodo: '}  ,oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
oGet1 := TGet():New(36,55,{|u| if(PCount()>0,cPeriodo:=u,cPeriodo)},oDlg,040,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"RCH",'cTGet1',,,, )

oSay2 := TSay():New(49,03,{||'Filial De: '}    ,oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
oGet2 := TGet():New(49,55,{|u| if(PCount()>0,cFilDe:=u,cFilDe)},oDlg,040,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SM0EMP",'cTGet2',,,, )

oSay3 := TSay():New(62,03,{||'Filial Ate: '}         ,oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
oGet3 := TGet():New(62,55,{|u| if(PCount()>0,cFilAte:=u,cFilAte)},oDlg,040,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SM0EMP",'cTGet3',,,, )

oSay4 := TSay():New(75,03,{||'Centro de Custo De: '}       ,oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
oGet4 := TGet():New(75,55,{|u| if(PCount()>0,cCustoDe:=u,cCustoDe)},oDlg,040,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"CTT",'cTGet4',,,, )

oSay5 := TSay():New(88,03,{||'Centro de Custo Ate:'},oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
oGet5 := TGet():New(88,55,{|u| if(PCount()>0,cCustoAte:=u,cCustoAte)},oDlg,040,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"CTT",'cTGet5',,,, )

oSay6 := TSay():New(101,03,{||'Matricula De:'},oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
oGet6 := TGet():New(101,55,{|u| if(PCount()>0,cMatDe:=u,cMatDe)},oDlg,040,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SRA",'cTGet6',,,, )

oSay7 := TSay():New(114,03,{||'Matricula Ate: '}    ,oDlg,,,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
oGet7 := TGet():New(114,55,{|u| if(PCount()>0,cMatAte:=u,cMatAte)},oDlg,040,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SRA",'cTGet7',,,, )

oSay8 := TSay():New(127,03,{||'Verbas: '}    ,oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)
@ 140,3 GET oMemo  VAR cVerbas MEMO SIZE 150,50 OF oDlg PIXEL 

oBtn1      := TButton():New( 190,003,"Verbas Ferias",oDlg,{|x| cVerbas := cVerFerias },045,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 190,050,"Verbas 13 Sal",oDlg,{|x| cVerbas := cVerSalar },045,012,,,,.T.,,"",,,,.F. )
oBtn3      := TButton():New( 190,100,"Verbas Custo" ,oDlg,{|x| cVerbas := cVerCusto },045,012,,,,.T.,,"",,,,.F. )

ACTIVATE MSDIALOG oDlg ON INIT enchoiceBar(oDlg, {|| Iif(lRet:=Valida(), oDlg:End(),)}, {|| oDlg:End()},,) CENTERED

return(lRet)

//Valida parâmetros 
Static Function Valida()
Local lRet := .T.

If Empty(cPeriodo) .or. Empty(cFilAte) .or. Empty(cCustoAte) .or. Empty(cMatAte)
    MsgAlert("Parametros incorretos.")
    lRet := .F.
Endif

Return(lRet)

//Le arquivo das verbas de custo
Static Function LeArqCusto()

Local cString  := ""
Local cArquivo := "\system\verbas_custo.txt"

nHandle := Ft_Fuse(cArquivo)
If nHandle == -1
   Return cString
EndIf

Ft_FGoTop() 
Do While !Ft_FEof()

    cLinha := Ft_FReadLn()
    cString += cLinha

    FT_FSkip()
EndDo
FT_FUse()   

Return(cString)

//Array que ira alimentar planilha
static function monta1Dados(cAuxAlias,nFlag)
    local aAux    := {}
    local nEspaco := 0
    local nCasas  := 0
    local nFator  := 0
    local cAnt    := ""
    local aDados  := {}

    while (cAuxAlias)->(!eof())
        if cAnt == (cAuxAlias)->RA_FILIAL + (cAuxAlias)->RA_MAT + (cAuxAlias)->VERBA + (cAuxAlias)->TIPPROV
            aDados[len(aDados),9]-=(cAuxAlias)->VALOR
        elseif substr((cAuxAlias)->DATAPGTO,1,6) == cPeriodo .or. nFlag == 1
            nEspaco := At(" ",(cAuxAlias)->RA_NOMECMP)
            nCasas := len((cAuxAlias)->RA_NOMECMP)-nEspaco
            nFator := iif((cAuxAlias)->RV_TIPOCOD=="2" .OR. (cAuxAlias)->VERBA $ '880,881,882,482',-1,1)
            
            aAdd(aAux,substr((cAuxAlias)->DATAPGTO,1,4))
            aAdd(aAux,substr((cAuxAlias)->DATAPGTO,5,2))
            aAdd(aAux,(cAuxAlias)->RA_ZZID)
            aAdd(aAux,substr((cAuxAlias)->RA_NOMECMP,1,nEspaco))
            aAdd(aAux,substr((cAuxAlias)->RA_NOMECMP,nEspaco,nCasas))
            aAdd(aAux,(cAuxAlias)->CONTACONTAB)
            aAdd(aAux,(cAuxAlias)->RV_DESC)
            aAdd(aAux,(cAuxAlias)->RA_ZZCOST)
            aAdd(aAux,(cAuxAlias)->VALOR*(nFator))
            aAdd(aAux,"BRL")
            aAdd(aAux, (cAuxAlias)->RA_FILIAL+(cAuxAlias)->RA_MAT+(cAuxAlias)->RA_ZZID+(cAuxAlias)->RA_ZZCOST+(cAuxAlias)->VERBA)
            aAdd(aAux,.F.)
            aAdd(aAux,(cAuxAlias)->VERBA)
            aAdd(aDados,aAux)
        endif
        
        cAnt := (cAuxAlias)->RA_FILIAL + (cAuxAlias)->RA_MAT + (cAuxAlias)->VERBA + (cAuxAlias)->TIPPROV
        aAux := {}
        (cAuxAlias)->(dbSkip())
    endDo

    (cAuxAlias)->(dbCloseArea())

return(aDados)

//Array que ira alimentar planilha
static function monta2Dados(cAuxAlias)
    local aAux    := {}
    local nEspaco := 0
    local nCasas  := 0
    local nFator  := 0
    local cAnt    := ""
    local aDados  := {}
    local lSubtrai := .F.

    cPerAnt := Substr(dtos(monthSub(lastday(stod(cPeriodo+"01")),1)),1,6)
    while (cAuxAlias)->(!eof())
        
        //alert(cPerAnt+" - "+Alltrim(cValtoChar((cAuxAlias)->RT_DFERPRO)))

        if cAnt == (cAuxAlias)->RA_FILIAL + (cAuxAlias)->RA_MAT + (cAuxAlias)->VERBA + (cAuxAlias)->TIPPROV
            aDados[len(aDados),9]-=(cAuxAlias)->VALOR
        elseif (substr((cAuxAlias)->DATAPGTO,1,6) == cPeriodo) .or.substr((cAuxAlias)->DATAPGTO,1,6) == cPerAnt 

            nEspaco := At(" ",(cAuxAlias)->RA_NOMECMP)
            nCasas := len((cAuxAlias)->RA_NOMECMP)-nEspaco
            nFator := iif((cAuxAlias)->RV_TIPOCOD=="2" .OR. (cAuxAlias)->VERBA $ '880,881,882,482',-1,1)
            
            aAdd(aAux,substr((cAuxAlias)->DATAPGTO,1,4))
            aAdd(aAux,substr((cAuxAlias)->DATAPGTO,5,2))
            aAdd(aAux,(cAuxAlias)->RA_ZZID)
            aAdd(aAux,substr((cAuxAlias)->RA_NOMECMP,1,nEspaco))
            aAdd(aAux,substr((cAuxAlias)->RA_NOMECMP,nEspaco,nCasas))
            aAdd(aAux,(cAuxAlias)->CONTACONTAB)
            aAdd(aAux,(cAuxAlias)->RV_DESC)
            aAdd(aAux,(cAuxAlias)->RA_ZZCOST)
            aAdd(aAux,(cAuxAlias)->VALOR*(nFator))
            aAdd(aAux,"BRL")
            aAdd(aAux, (cAuxAlias)->RA_FILIAL+(cAuxAlias)->RA_MAT+(cAuxAlias)->RA_ZZID+(cAuxAlias)->RA_ZZCOST+(cAuxAlias)->VERBA)

            If substr((cAuxAlias)->DATAPGTO,1,6) == cPerAnt .and. (cAuxAlias)->RT_DFERPRO == 27.5
                lSubtrai := .T.
            Else
               lSubtrai := .F. 
            Endif
            aAdd(aAux,lSubtrai)
            aAdd(aAux,(cAuxAlias)->VERBA)
            aAdd(aAux,(cAuxAlias)->RA_FILIAL)
            aAdd(aAux,(cAuxAlias)->RA_MAT)
            aAdd(aDados,aAux)
        endif
        
        cAnt := (cAuxAlias)->RA_FILIAL + (cAuxAlias)->RA_MAT + (cAuxAlias)->VERBA + (cAuxAlias)->TIPPROV
        aAux := {}
        (cAuxAlias)->(dbSkip())
    endDo

    (cAuxAlias)->(dbCloseArea())

Return(aDados)

Static Function MontaVet(aVetor1, aVetor2)
local aDadosDef := {}
local aDados2   := {}
local cAliasSUB := GetNextAlias()
local lSubtrai  := .F.
local cPerAnt   := Substr(dtos(monthSub(lastday(stod(cPeriodo+"01")),1)),1,6)  

DBSelectArea("RCA")
Dbsetorder(1)
If Dbseek(xFilial("RCA")+"M_REL_FERIAS")
    cVerFerias := Alltrim(RCA->RCA_CONTEU)
Endif

For nX:=1 to Len(aVetor1)

    cChave := aVetor1[nX,11]

    nPos := aScan(aDados2,{|x|Alltrim(x[11])==cChave})
    If nPos = 0
        aAdd(aDados2,aVetor1[nX])
    Else
        aDados2[nPos,09] += aVetor1[nX,09]
    Endif
    
Next nX

For nT:=1 to Len(aVetor1)
    aAdd(aDadosDef,aVetor1[nT])
Next nT

For nX:=1 to Len(aVetor2)

    cChave := aVetor2[nX,11]

    nPos := aScan(aDados2,{|x|Alltrim(x[11])==cChave})
    If nPos = 0
        aAdd(aDados2,aVetor2[nX])
    Else

        lSubtrai := .F.
        BeginSQL Alias cAliasSUB
			SELECT COUNT(*) REGS
			FROM %Table:SRT% SRT
			WHERE RT_FILIAL = %Exp:aVetor2[nX,14]%
			AND RT_MAT = %Exp:aVetor2[nX,15]%
			AND Substring(RT_DATACAL,1,6) = %Exp:cPerAnt%
			AND RT_VERBA = '830'
            AND RT_DFERPRO = 27.5
			AND SRT.%NotDel%
		EndSQL
		If (cAliasSUB)->REGS > 0
            lSubtrai := .T.
		Endif
		(cAliasSUB)->(DbCloseArea())

        If aVetor2[nX,12] .or. lSubtrai //( aVetor2[nX,13] $ cVerFerias )
            aDados2[nPos,09] -= aVetor2[nX,09]
        Else
            aDados2[nPos,09] += aVetor2[nX,09]
        Endif
    Endif
    
Next nX

For nB:=1 to Len(aVetor2)

    For nM:=1 to 2

        cVerBaixa := ""
        Do case
            Case aVetor2[nB,13] == "830" 
                cVerBaixa := Iif(nM==1,"880","890")
            Case aVetor2[nB,13] == "831" 
                cVerBaixa := Iif(nM==1,"881","891")
            Case aVetor2[nB,13] == "832" 
                cVerBaixa := Iif(nM==1,"882","892")
            Case aVetor2[nB,13] == "833" 
                cVerBaixa := Iif(nM==1,"883","893")
            Case aVetor2[nB,13] == "834" 
                cVerBaixa := Iif(nM==1,"884","894")
            Case aVetor2[nB,13] == "845" 
                cVerBaixa := Iif(nM==1,"966","910")
            Case aVetor2[nB,13] == "846" 
                cVerBaixa := Iif(nM==1,"967","911")
            Case aVetor2[nB,13] == "847" 
                cVerBaixa := Iif(nM==1,"968","912")
            Case aVetor2[nB,13] == "848" 
                cVerBaixa := Iif(nM==1,"969","913")
        EndCase

        If !Empty(cVerBaixa)
            cAliasBX := GetNextAlias()
            BeginSQL Alias cAliasBX
                SELECT SUM(RT_VALOR) VALOR
                FROM %Table:SRT% SRT
                WHERE RT_FILIAL = %Exp:aVetor2[nB,14]%
                AND RT_MAT = %Exp:aVetor2[nB,15]%
                AND Substring(RT_DATACAL,1,6) = %Exp:cPeriodo%
                AND RT_VERBA = %Exp:cVerBaixa%
                AND SRT.%NotDel%
            EndSQL
            If (cAliasBX)->VALOR > 0
                aVetor2[nB,09] -= (cAliasBX)->VALOR
            Endif
            (cAliasBX)->(DbCloseArea())        
        Endif
    Next nM

Next nB

For nT:=1 to Len(aVetor2)
    aAdd(aDadosDef,aVetor2[nT])
Next nT

asort(aDadosDef, , ,{|x,y|x[3] > y[3]})

/*For nX:=1 to Len(aDadosDef)

    cChave := aDadosDef[nX,11]

    nPos := aScan(aDados2,{|x|Alltrim(x[11])==cChave})
    If nPos = 0
        aAdd(aDados2,aDadosDef[nX])
    Else
        aDados2[nPos,09] -= aDadosDef[nX,09]
    Endif
    
Next nX*/

aDadosDef := {}
For nZ:=1 to Len(aDados2)
    aAux := {}
    aAdd(aAux,aDados2[nZ,01])
    aAdd(aAux,aDados2[nZ,02])
    aAdd(aAux,aDados2[nZ,03])
    aAdd(aAux,aDados2[nZ,04])
    aAdd(aAux,aDados2[nZ,05])
    aAdd(aAux,aDados2[nZ,06])
    aAdd(aAux,aDados2[nZ,13])
    aAdd(aAux,aDados2[nZ,07])
    aAdd(aAux,aDados2[nZ,08])
    aAdd(aAux,aDados2[nZ,09])
    aAdd(aAux,aDados2[nZ,10])
    aAdd(aDadosDef,aAux)
Next nZ

return(aDadosDef)

//Criaçao do arquivo para excel
static function criaPlanilha(aDados,cDir)
    local oExcel    := FWMsExcel():New()
    local cTitulo   := "RelatorioGerencial_"+DTOS(dDatabase)+"_"+STRTRAN(Time(),":","")
    local cTable := cTitulo
    local cTitulo2  := "Periodo " + cPeriodo
    local cPlanilha := "Dados"
    local nI        := 1


    criaAba(oExcel,cTitulo)

    for nI := 1 to len(aDados)
        oExcel:AddRow(cPlanilha,cTable, aDados[nI])
    next nI

    GeraRel(oExcel,cDir, cTitulo)

return

//Criaçao dos campos da planilha
static function criaAba(oExcel,cTitulo)
    local cTable := cTitulo
    local cPlanilha := "Dados"

    oExcel:AddWorkSheet(cPlanilha)

    oExcel:AddTable (cPlanilha, cTable)

    oExcel:AddColumn(cPlanilha, cTable, "YEAR"               , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "MONTH"              , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "PAYROLL_EMPLOYEE_ID", 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "FIRST_NAME"         , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "LAST_NAME"          , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "PAYROLL_COST_ID"    , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "VERBA"              , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "PAYROLL_COST_DESC"  , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "COST_CENTER_ID"     , 1, 1)
    oExcel:AddColumn(cPlanilha, cTable, "AMOUNT"             , 3, 2)
    oExcel:AddColumn(cPlanilha, cTable, "CURRENCY"           , 1, 1)


return


Static Function GeraRel(oExcel, cDir, cTitulo)
    Local oExcelApp

    If !lIsDir(cDir)
        MontaDir(cDir)
    Endif

    oExcel:Activate()
    cArq := CriaTrab(Nil, .F.) + ".xml"
    oExcel:GetXMLFile(cArq)
    oExcel:DeActivate()

    // if __CopyFile( cArq, cDir + strTran(cTitulo,"xml","xls"))
    if __CopyFile( cArq, cDir + cTitulo+".xls")
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open( cDir + cTitulo + ".xls" )
        oExcelApp:SetVisible(.T.)
    endif

Return

