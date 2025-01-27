#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'

/*=============================================================
* Funcao		:	RHGERENC
* Autor			:	Mauricio Dizimbat - TOTVS IP
* Data			: 	07/05/2021
* Descricao		:	Relatorio Gerencial de Folha de Pagamento
==============================================================*/

User Function RHGERENC()

Private cPeriodo  := SPACE(getSx3Cache("RC_PERIODO","X3_TAMANHO"))
Private cFilDe    := SPACE(getSx3Cache("RA_FILIAL","X3_TAMANHO"))
Private cFilAte   := Padr('',getSx3Cache("RA_FILIAL","X3_TAMANHO"),'ZZ')
Private cCustoDe  := SPACE(getSx3Cache("CTT_CUSTO","X3_TAMANHO"))
Private cCustoAte := Padr('',getSx3Cache("CTT_CUSTO","X3_TAMANHO"),'ZZ')
Private cMatDe    := SPACE(getSx3Cache("RA_MAT","X3_TAMANHO"))
Private cMatAte   := Padr('',getSx3Cache("RA_MAT","X3_TAMANHO"),'ZZ')
Private cVerbas   := SPACE(1000)
Private cAliasTMP
Private cPerAnt
Private oArqTemp
Private cTabBD
Private cVerFerias := ""
Private cVerSalar  := ""
Private cVerbasBX  := ""

if perg()
    FwMsgRun( Nil , { || montaExcel() } , 'Processando' , "Gerando Relatorio...   " )
endif

Return

/*============================================
    Tela de parâmetros
============================================*/
Static Function Perg()

local lRet       := .F.
Local cMemo		 := ""
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

DBSelectArea("RCA")
Dbsetorder(1)
If Dbseek(xFilial("RCA")+"M_REL_BAIX")
    cVerbasBX  := Alltrim(RCA->RCA_CONTEU)
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

/*============================================
    Valida parâmetros
============================================*/
Static Function Valida()
Local lRet := .T.

If Empty(cPeriodo) .or. Empty(cFilAte) .or. Empty(cCustoAte) .or. Empty(cMatAte)
    MsgAlert("Parametros incorretos.")
    lRet := .F.
Endif

Return(lRet)

/*============================================
    Processamento
============================================*/
static function montaExcel()

Local aVetor := {}

cPerAnt := Substr(dtos(monthSub(lastday(stod(cPeriodo+"01")),1)),1,6)  

//Gera tabela temporaria
GetTabBD()
cQuery := "SELECT * FROM " + cTabBD + " ORDER BY RA_FILIAL, RA_MAT, VERBA"
Tcquery cQuery NEW ALIAS (cAliasDEF := GetNextAlias())
While !(cAliasDEF)->(EOF())

    aAux := {}
    aAdd(aAux,(cAliasDEF)->YEAR)
    aAdd(aAux,(cAliasDEF)->MONTH)
    aAdd(aAux,(cAliasDEF)->RA_ZZID)
    aAdd(aAux,(cAliasDEF)->FIRST_NAME)
    aAdd(aAux,(cAliasDEF)->LAST_NAME)
    aAdd(aAux,(cAliasDEF)->CONTACTB)
    aAdd(aAux,(cAliasDEF)->VERBA)
    aAdd(aAux,(cAliasDEF)->RV_DESC)
    aAdd(aAux,(cAliasDEF)->RA_ZZCOST)
    aAdd(aAux,(cAliasDEF)->VALORDEF)
    aAdd(aAux,(cAliasDEF)->CURRENCY)

    aAdd(aVetor,aAux)

    (cAliasDEF)->(Dbskip())
Enddo

if len(aVetor) > 0
    cDir := cGetFile('*.xls|*.xls',"Selecione diretorio",,,.F.,GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY  ,.T.)
    if !empty(cDir)
        criaPlanilha(aVetor,cDir)
    endif
else
    msgAlert("Nao ha registros para os parâmetros selecionados. Impressao sera cancelada.")
endif

Return

/*============================================
    Gera tabela temporaria no BD
============================================*/
Static Function GetTabBD()

cAliasTMP := GetNextAlias()
cAuxTabela := ""

aCampos := {}

//SRA - Funcionarios
AADD(aCampos,{ "RA_FILIAL"	, GetSx3Cache("RA_FILIAL","X3_TIPO") , GetSx3Cache("RA_FILIAL","X3_TAMANHO")    , GetSx3Cache("RA_FILIAL","X3_DECIMAL")  })
AADD(aCampos,{ "RA_MAT"	    , GetSx3Cache("RA_MAT","X3_TIPO")    , GetSx3Cache("RA_MAT","X3_TAMANHO")       , GetSx3Cache("RA_MAT","X3_DECIMAL")     })
AADD(aCampos,{ "RA_NOMECMP"	, GetSx3Cache("RA_NOMECMP","X3_TIPO"), GetSx3Cache("RA_NOMECMP","X3_TAMANHO")   , GetSx3Cache("RA_NOMECMP","X3_DECIMAL") })
AADD(aCampos,{ "FIRST_NAME"	, GetSx3Cache("RA_NOMECMP","X3_TIPO"), GetSx3Cache("RA_NOMECMP","X3_TAMANHO")   , GetSx3Cache("RA_NOMECMP","X3_DECIMAL") })
AADD(aCampos,{ "LAST_NAME"	, GetSx3Cache("RA_NOMECMP","X3_TIPO"), GetSx3Cache("RA_NOMECMP","X3_TAMANHO")   , GetSx3Cache("RA_NOMECMP","X3_DECIMAL") })
AADD(aCampos,{ "RA_ZZID"	, GetSx3Cache("RA_ZZID","X3_TIPO")   , GetSx3Cache("RA_ZZID","X3_TAMANHO")      , GetSx3Cache("RA_ZZID","X3_DECIMAL")    })
AADD(aCampos,{ "RA_ZZCOST"	, GetSx3Cache("RA_ZZCOST","X3_TIPO") , GetSx3Cache("RA_ZZCOST","X3_TAMANHO")    , GetSx3Cache("RA_ZZCOST","X3_DECIMAL")  })
//SRV - Verbas
AADD(aCampos,{ "VERBA"	    , GetSx3Cache("RC_PD","X3_TIPO")     , GetSx3Cache("RC_PD","X3_TAMANHO")        , GetSx3Cache("RC_PD","X3_DECIMAL")      })
AADD(aCampos,{ "RV_DESC"	, GetSx3Cache("RV_DESC","X3_TIPO")   , GetSx3Cache("RV_DESC","X3_TAMANHO")      , GetSx3Cache("RV_DESC","X3_DECIMAL")    })
AADD(aCampos,{ "RV_TIPOCOD"	, GetSx3Cache("RV_TIPOCOD","X3_TIPO"), GetSx3Cache("RV_TIPOCOD","X3_TAMANHO")   , GetSx3Cache("RV_TIPOCOD","X3_DECIMAL") })
AADD(aCampos,{ "CONTACTB", GetSx3Cache("RV_DEBITO","X3_TIPO") , GetSx3Cache("RV_DEBITO","X3_TAMANHO")    , GetSx3Cache("RV_DEBITO","X3_DECIMAL")  })
//Periodos
AADD(aCampos,{ "PERATUAL"	, "C"                                , 6                                        , 0                                      })
AADD(aCampos,{ "PERANTER"	, "C"                                , 6                                        , 0                                      })
AADD(aCampos,{ "YEAR"   	, "C"                                , 4                                        , 0                                      })
AADD(aCampos,{ "MONTH"   	, "C"                                , 2                                        , 0                                      })
//Valores
AADD(aCampos,{ "TIP1ATUAL"	, GetSx3Cache("RC_VALOR","X3_TIPO")  , GetSx3Cache("RC_VALOR","X3_TAMANHO")     , GetSx3Cache("RC_VALOR","X3_DECIMAL")   })
AADD(aCampos,{ "TIP2ATUAL"	, GetSx3Cache("RC_VALOR","X3_TIPO")  , GetSx3Cache("RC_VALOR","X3_TAMANHO")     , GetSx3Cache("RC_VALOR","X3_DECIMAL")   })
AADD(aCampos,{ "TIP1ANTE"	, GetSx3Cache("RC_VALOR","X3_TIPO")  , GetSx3Cache("RC_VALOR","X3_TAMANHO")     , GetSx3Cache("RC_VALOR","X3_DECIMAL")   })
AADD(aCampos,{ "TIP2ANTE"	, GetSx3Cache("RC_VALOR","X3_TIPO")  , GetSx3Cache("RC_VALOR","X3_TAMANHO")     , GetSx3Cache("RC_VALOR","X3_DECIMAL")   })
AADD(aCampos,{ "VALORDEF"	, GetSx3Cache("RC_VALOR","X3_TIPO")  , GetSx3Cache("RC_VALOR","X3_TAMANHO")     , GetSx3Cache("RC_VALOR","X3_DECIMAL")   })
AADD(aCampos,{ "CURRENCY"	, "C"                                , 3                                        , 0                                      })
//Especificos Provisão
AADD(aCampos,{ "RT_DFERPRO"	, GetSx3Cache("RT_DFERPRO","X3_TIPO"), GetSx3Cache("RT_DFERPRO","X3_TAMANHO")   , GetSx3Cache("RT_DFERPRO","X3_DECIMAL") })
AADD(aCampos,{ "RT_SALARIO"	, GetSx3Cache("RT_SALARIO","X3_TIPO"), GetSx3Cache("RT_SALARIO","X3_TAMANHO")   , GetSx3Cache("RT_SALARIO","X3_DECIMAL") })
AADD(aCampos,{ "DIFSAL"	    , GetSx3Cache("RT_SALARIO","X3_TIPO"), GetSx3Cache("RT_SALARIO","X3_TAMANHO")   , GetSx3Cache("RT_SALARIO","X3_DECIMAL") })
AADD(aCampos,{ "RT_DFERVEN"	, GetSx3Cache("RT_DFERVEN","X3_TIPO"), GetSx3Cache("RT_DFERVEN","X3_TAMANHO")   , GetSx3Cache("RT_DFERVEN","X3_DECIMAL") })
//Outros
AADD(aCampos,{ "TAB"	    , "C"                                , 3                                        , 0                                      })

oArqTemp := FWTemporaryTable():New(cAliasTMP,aCampos)
oArqTemp:Create()

cTabBD := oArqTemp:GetRealName()

fGetRegs()

//Alert(cTabBD)

Return()

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

/*=====================================================
    Preenche dados iniciais
======================================================*/
Static Function fGetRegs()

local cAlias     := getNextAlias()
local cVerbasFil := filtroVerbas()
local cVerFilCT2 := filtroCT2Ver()
local cQuery     := ""
local aDifSal    := {}
local cVerb      := ""

cQuery += " SELECT * FROM " + CRLF
cQuery += "(" + CRLF

//Busca na SRC
cQuery += "SELECT RA_FILIAL, " + CRLF
cQuery += " RA_MAT, " + CRLF
cQuery += " RA_NOMECMP, " + CRLF
cQuery += " RA_CC, " + CRLF
cQuery += " RA_ZZID, " + CRLF
cQuery += " RA_ZZCOST, " + CRLF
cQuery += " RC_PD VERBA, " + CRLF
cQuery += " RV_DESC, " + CRLF
cQuery += " RV_TIPOCOD, " + CRLF
cQuery += " CASE WHEN RV_TIPOCOD = '1' OR RV_TIPOCOD = '3'  THEN RV_DEBITO " + CRLF
cQuery += "      WHEN RV_TIPOCOD = '2' THEN RV_CREDITO "                     + CRLF
cQuery += "      ELSE NULL END                              AS CONTACTB, " + CRLF
cQuery += " 0 AS VALOR, " + CRLF
cQuery += " 'SRC' AS TAB  " + CRLF
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

//Busca na SRD
cQuery += " UNION " + CRLF
cQuery += " SELECT RA_FILIAL, " + CRLF
cQuery += " RA_MAT, " + CRLF
cQuery += " RA_NOMECMP, " + CRLF
cQuery += " RA_CC, " + CRLF
cQuery += " RA_ZZID, " + CRLF
cQuery += " RA_ZZCOST, " + CRLF
cQuery += " RD_PD VERBA, " + CRLF
cQuery += " RV_DESC, " + CRLF
cQuery += " RV_TIPOCOD, " + CRLF
cQuery += " CASE WHEN RV_TIPOCOD = '1'  OR RV_TIPOCOD = '3' THEN RV_DEBITO " + CRLF
cQuery += "      WHEN RV_TIPOCOD = '2' THEN RV_CREDITO "                     + CRLF
cQuery += "      ELSE NULL END                              AS CONTACTB, " + CRLF
cQuery += " 0 AS VALOR, " + CRLF
cQuery += " 'SRD' AS TAB  " + CRLF
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

//Busca na SRT
cQuery += " UNION " + CRLF
cQuery += " SELECT RA_FILIAL, " + CRLF
cQuery += " RA_MAT, " + CRLF
cQuery += " RA_NOMECMP, " + CRLF
cQuery += " RA_CC, " + CRLF
cQuery += " RA_ZZID, " + CRLF
cQuery += " RA_ZZCOST, " + CRLF
cQuery += " RT_VERBA VERBA, " + CRLF
cQuery += " RV_DESC, " + CRLF
cQuery += " RV_TIPOCOD, " + CRLF
cQuery += " CASE WHEN RV_TIPOCOD = '1'  OR RV_TIPOCOD = '3' THEN RV_DEBITO " + CRLF
cQuery += "      WHEN RV_TIPOCOD = '2' THEN RV_CREDITO "                     + CRLF
cQuery += "      ELSE NULL END                              AS CONTACTB, " + CRLF
cQuery += " 0 AS VALOR, " + CRLF
cQuery += " 'SRT' AS TAB  " + CRLF
cQuery += " FROM " + retSqlTab("SRA") + CRLF
cQuery += "  INNER JOIN " + retSqlTab("SRT") + CRLF
cQuery += "   ON RT_FILIAL = RA_FILIAL " + CRLF
cQuery += "   AND RT_MAT = RA_MAT " + CRLF
cQuery += "   AND SUBSTRING(RT_DATACAL,1,6) = '" + cPeriodo + "' " + CRLF
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

//Busca na ct2
//CT2_HIST:
//MATRICULA - 000026- VERBA -848 - FGTS PR  
cQuery += " UNION " + CRLF
cQuery += " SELECT CT2_FILIAL AS RA_FILIAL, " + CRLF
cQuery += " SUBSTRING(CT2_HIST,13,6) AS RA_MAT, " + CRLF
cQuery += " RA_NOMECMP, " + CRLF
cQuery += " RA_CC, " + CRLF
cQuery += " RA_ZZID, " + CRLF
cQuery += " RA_ZZCOST, " + CRLF          
cQuery += " SUBSTRING(CT2_HIST,28,3) AS VERBA, " + CRLF
cQuery += " RV_DESC, " + CRLF
cQuery += " RV_TIPOCOD, " + CRLF
cQuery += " CASE WHEN SUBSTRING(CT2_HIST,28,3) IN "+FormatIn(cVerbasBX,';') +" THEN RV_CREDITO  " + CRLF
cQuery += "      ELSE RV_DEBITO END                              AS CONTACTB, " + CRLF
//cQuery += " CASE WHEN RV_TIPOCOD = '1'  OR RV_TIPOCOD = '3' THEN RV_DEBITO " + CRLF
//cQuery += "      WHEN RV_TIPOCOD = '2' THEN RV_CREDITO "                     + CRLF
//cQuery += "      ELSE NULL END                              AS CONTACTB, " + CRLF
cQuery += " CASE WHEN SUBSTRING(CT2_ORIGEM,8,3) = '002' AND SUBSTRING(CT2_ORIGEM,4,1) = 'P' THEN CT2_VALOR * -1 " + CRLF
cQuery += "      ELSE CT2_VALOR END                              AS VALOR, " + CRLF
//cQuery += " CT2_VALOR AS VALOR, " + CRLF
cQuery += " 'CT2' AS TAB  " + CRLF
cQuery += " FROM " + retSqlTab("CT2") + CRLF
cQuery += "  INNER JOIN " + retSqlTab("SRV") + CRLF
cQuery += "   ON RV_FILIAL = '" + xFilial("SRV") + "' " + CRLF
cQuery += "   AND RV_COD = SUBSTRING(CT2_HIST,28,3) " + CRLF
cQuery += "   AND SRV.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  INNER JOIN " + retSqlTab("SRT") + CRLF
cQuery += "   ON RT_FILIAL = '" + xFilial("SRT") + "' " + CRLF
cQuery += "   AND RT_VERBA = SUBSTRING(CT2_HIST,28,3) " + CRLF
cQuery += "   AND SRT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  INNER JOIN " + retSqlTab("SRA") + CRLF
cQuery += "   ON RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "' " + CRLF
cQuery += "   AND RA_FILIAL = CT2_FILIAL " + CRLF
cQuery += "   AND RA_MAT = SUBSTRING(CT2_HIST,13,6) " + CRLF
cQuery += "   AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "' " + CRLF
cQuery += "   AND RA_CC BETWEEN '"+ cCustoDe + "' AND '" + cCustoAte + "' " + CRLF
cQuery += "   AND SRA.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "  WHERE CT2_LOTE = '008890' " + CRLF
cQuery += "   AND CT2_DC <> '4' " + CRLF
//cQuery += "   AND CT2_DATA = '"+lastday(stod(cPeriodo+"01"))+"' "
cQuery += "   AND SUBSTRING(CT2_DATA,1,6) = '"+cPeriodo+"' "
cQuery += cVerFilCT2 + CRLF
cQuery += "   AND CT2.D_E_L_E_T_ = '' " + CRLF

cQuery += ") TEMP " + CRLF
cQuery += " WHERE SUBSTRING(CONTACTB,1,1) <> '1' AND SUBSTRING(CONTACTB,1,1) <> '2' " + CRLF
cQuery += " GROUP BY RA_FILIAL, RA_MAT, RA_NOMECMP, RA_CC, RA_ZZID, RA_ZZCOST, VERBA, RV_DESC, RV_TIPOCOD, CONTACTB, VALOR, TAB " + CRLF
cQuery += " ORDER BY RA_FILIAL, RA_MAT, VERBA " + CRLF

MemoWrite("C:\Temp\qry1.txt", cQuery)

TcQuery cQuery new Alias(cAlias1:=GetNextAlias())
While !(cAlias1)->(EOF())

    Reclock(cAliasTMP,.T.)
        
        (cAliasTMP)->RA_FILIAL   := (cAlias1)->RA_FILIAL
        (cAliasTMP)->RA_MAT      := (cAlias1)->RA_MAT
        (cAliasTMP)->RA_NOMECMP  := (cAlias1)->RA_NOMECMP
        (cAliasTMP)->FIRST_NAME  := ""
        (cAliasTMP)->LAST_NAME   := ""
        (cAliasTMP)->RA_ZZID     := (cAlias1)->RA_ZZID
        (cAliasTMP)->RA_ZZCOST   := (cAlias1)->RA_ZZCOST

        (cAliasTMP)->VERBA       := (cAlias1)->VERBA
        (cAliasTMP)->RV_DESC     := (cAlias1)->RV_DESC
        (cAliasTMP)->RV_TIPOCOD  := (cAlias1)->RV_TIPOCOD
        (cAliasTMP)->CONTACTB := (cAlias1)->CONTACTB

        (cAliasTMP)->PERATUAL    := cPeriodo 
        (cAliasTMP)->PERANTER    := cPerAnt
        (cAliasTMP)->YEAR        := substr(cPeriodo,1,4)
        (cAliasTMP)->MONTH       := substr(cPeriodo,5,2)   

        (cAliasTMP)->TIP1ATUAL   := 0
        (cAliasTMP)->TIP2ATUAL   := 0
        (cAliasTMP)->TIP1ANTE    := 0
        (cAliasTMP)->TIP2ANTE    := 0
        If (cAlias1)->TAB = "CT2"
            (cAliasTMP)->VALORDEF    := (cAlias1)->VALOR
        Else
            (cAliasTMP)->VALORDEF    := 0
        ENDIF

        //(cAliasTMP)->RT_DFERPRO  := (cAlias1)->RT_DFERPRO
        //(cAliasTMP)->RT_SALARIO  := (cAlias1)->RT_SALARIO
        //(cAliasTMP)->DIFSAL      := 0
        //(cAliasTMP)->RT_DFERVEN  := (cAlias1)->RT_DFERVEN
        (cAliasTMP)->TAB         := (cAlias1)->TAB
        (cAliasTMP)->CURRENCY    := "BRL"

     (cAliasTMP)->(Msunlock())

    (cAlias1)->(Dbskip())
Enddo
cMsg := ""
Dbselectarea(cAliasTMP)
Dbgotop()
cChave  := (cAliasTMP)->RA_FILIAL+(cAliasTMP)->RA_MAT
lDifSal := .F.
While !(cAliasTMP)->(EOF())
    
    If (cAliasTMP)->RA_FILIAL+(cAliasTMP)->RA_MAT <> cChave
        cChave := (cAliasTMP)->RA_FILIAL+(cAliasTMP)->RA_MAT
        lDifSal := .F.
        lFerProp := .F.
    Endif

    nEspaco := At(" ",(cAliasTMP)->RA_NOMECMP)
    nCasas  := len((cAliasTMP)->RA_NOMECMP)-nEspaco
    nFator  := iif((cAliasTMP)->RV_TIPOCOD=="2" .OR. (cAliasTMP)->VERBA $ '880,881,882,482',-1,1)

    nVlrDef    := 0
    nTip1Atual := 0
    nTip2Atual := 0
    nTip1Anter := 0
    nTip2Anter := 0
    nSalAtual  := 0
    nSalAnter  := 0

    If (cAliasTMP)->TAB == "SRC" .or. (cAliasTMP)->TAB == "SRD" .or. (cAliasTMP)->TAB == "SRT"

        nCont  := 0
        cQuery := "SELECT  RC_VALOR VALOR " 
        cQuery += " FROM " + retSqlTab("SRC") + CRLF
        cQuery += "  WHERE RC_FILIAL = '"+(cAliasTMP)->RA_FILIAL+"' " + CRLF
        cQuery += "    AND RC_MAT = '"+(cAliasTMP)->RA_MAT+"' " + CRLF
        cQuery += "    AND RC_PERIODO = '" + cPeriodo + "' " + CRLF
        cQuery += "    AND RC_PD = '"+(cAliasTMP)->VERBA+"' " + CRLF
        cQuery += "    AND SRC.D_E_L_E_T_ = ' ' " + CRLF
        cQuery += "UNION " + CRLF
        cQuery += "SELECT  RD_VALOR VALOR "
        cQuery += " FROM " + retSqlTab("SRD") + CRLF
        cQuery += "  WHERE RD_FILIAL = '"+(cAliasTMP)->RA_FILIAL+"' " + CRLF
        cQuery += "    AND RD_MAT = '"+(cAliasTMP)->RA_MAT+"' " + CRLF
        cQuery += "    AND RD_PERIODO = '" + cPeriodo + "' " + CRLF
        cQuery += "    AND RD_PD = '"+(cAliasTMP)->VERBA+"' " + CRLF
        cQuery += "    AND SRD.D_E_L_E_T_ = ' ' " + CRLF
        If (cAliasTMP)->VERBA == '853'.OR.(cAliasTMP)->VERBA == '968' 
            cQuery += "SELECT  RT_VALOR VALOR "
            cQuery += " FROM " + retSqlTab("SRT") + CRLF
            cQuery += "  WHERE RT_FILIAL = '"+(cAliasTMP)->RA_FILIAL+"' " + CRLF
            cQuery += "    AND RT_MAT = '"+(cAliasTMP)->RA_MAT+"' " + CRLF
            cQuery += "    AND SUBSTRING(RT_DATACAL,1,6) = '" + cPeriodo + "' " + CRLF
            cQuery += "    AND RT_VERBA IN ('968','853') " + CRLF
            cQuery += "    AND SRT.D_E_L_E_T_ = ' ' " + CRLF
        ENDIF    
        TcQuery cQuery new Alias(cAlias1:=GetNextAlias())
        While !(cAlias1)->(EOF())
            cVerb:= (cAliasTMP)->VERBA 
            nCont++
            If nCont = 1
                nVlrDef := (cAlias1)->VALOR * nFator
            Elseif cVerb='756'.or.cVerb='815'.or.cVerb='816'.or.cVerb='817'
                nVlrDef += (cAlias1)->VALOR * nFator    
            Else
               nVlrDef -= (cAlias1)->VALOR
            Endif
            (cAlias1)->(Dbskip())
        Enddo
        Dbclosearea(cAlias1)

        Reclock(cAliasTMP,.F.)   
            (cAliasTMP)->FIRST_NAME := substr((cAliasTMP)->RA_NOMECMP,1,nEspaco)
            (cAliasTMP)->LAST_NAME  := substr((cAliasTMP)->RA_NOMECMP,nEspaco,nCasas)
            (cAliasTMP)->VALORDEF   := nVlrDef
        Msunlock()

    Elseif (cAliasTMP)->TAB == "CT2"

        nVlrDef := (cAliasTMP)->VALORDEF
        //Deixa aparecer negativo caso a verba seja de baixa
        If Alltrim((cAliasTMP)->VERBA) $ cVerbasBX
            If nVlrDef > 0
                nVlrDef := nVlrDef * -1
            Endif
        Endif

        Dbselectarea("SRA")
        Dbsetorder(1)
        Dbseek((cAliasTMP)->RA_FILIAL+(cAliasTMP)->RA_MAT)      

        Dbselectarea("SRV")
        Dbsetorder(1)
        Dbseek(xFilial("SRV")+(cAliasTMP)->VERBA)

        If SRV->RV_TIPOCOD = '1' .OR. SRV->RV_TIPOCOD = '3'
            cContaCTB := SRV->RV_DEBITO
        ElseIf SRV->RV_TIPOCOD = '2'
            cContaCTB := SRV->RV_CREDITO
        Else
            cContaCTB := ''
        Endif    

        Reclock(cAliasTMP,.F.)   
            //(cAliasTMP)->RA_NOMECMP := SRA->RA_NOMECMP
            (cAliasTMP)->FIRST_NAME := substr(SRA->RA_NOMECMP,1,nEspaco)
            (cAliasTMP)->LAST_NAME  := substr(SRA->RA_NOMECMP,nEspaco,nCasas)
            (cAliasTMP)->VALORDEF   := nVlrDef
            //(cAliasTMP)->RA_ZZID    := SRA->RA_ZZID
            //(cAliasTMP)->RA_ZZCOST  := SRA->RA_ZZCOST
            //(cAliasTMP)->RV_DESC    := SRV->RV_DESC
            //(cAliasTMP)->RV_TIPOCOD := SRV->RV_TIPOCOD
            //(cAliasTMP)->CONTACTB   := cContaCTB
        Msunlock()
                  
    Endif    


    (cAliasTMP)->(Dbskip())
Enddo    
//MostraLog(cMsg) 
/* COMENTADO O AJUSTE DA DIFERENÇA SALARIAL
cLogUpdate := ""
For nX:=1 to Len(aDifSal)

    If aDifSal[nX,4] > 0
        nVlrNovo := 0
        cSelect := "SELECT VALORDEF FROM " + cTabBD 
        cSelect += " WHERE RA_FILIAL = '"+aDifSal[nX,1]+"' "
        cSelect += " AND RA_MAT = '"+aDifSal[nX,2]+"' "
        cSelect += " AND VERBA = '"+aDifSal[nX,3]+"' "    
        TcQuery cSelect new Alias(cAliasSEL:=GetNextAlias())
        nVlrNovo := (cAliasSEL)->VALORDEF + aDifSal[nX,4]
        Dbclosearea(cAliasSEL)
        
        If nVlrNovo > 0
            cUpdate := "UPDATE "+cTabBD+" SET VALORDEF = "+Alltrim(cValtoChar(nVlrNovo))
            cUpdate += " WHERE RA_FILIAL = '"+aDifSal[nX,1]+"' "
            cUpdate += " AND RA_MAT = '"+aDifSal[nX,2]+"' "
            cUpdate += " AND VERBA = '"+aDifSal[nX,3]+"' "
            cLogUpdate += cUpdate + CRLF
            TcSqlExec(cUpdate)
        Endif
    Endif

Next nX

MemoWrite("C:\temp\cLogUpdate.txt", cLogUpdate) 
*/
Dbclosearea(cAlias1)

Return

/*===============================================
    Criaçao do arquivo para excel
================================================*/
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

/*===============================================
    Realiza filtro de verbas informados no memo
================================================*/
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

/*===============================================
    Realiza filtro de verbas informados no memo
================================================*/
static function filtroCT2Ver()
    local cRet    := ""
    local aVerbas := strTokArr(Alltrim(cVerbas),";")
    local nI      := 1

    if len(aVerbas) > 0
        cRet += " AND SUBSTRING(CT2_HIST,28,3) IN ("
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

/*===============================================
    Criaçao dos campos da planilha
================================================*/
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

/*===============================================
    Gera Relatorio
================================================*/
Static Function GeraRel(oExcel, cDir, cTitulo)

Local oExcelApp

If !lIsDir(cDir)
    MontaDir(cDir)
Endif

oExcel:Activate()
cArq := CriaTrab(Nil, .F.) + ".xml"
oExcel:GetXMLFile(cArq)
oExcel:DeActivate()

if __CopyFile( cArq, cDir + cTitulo+".xls")
    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open( cDir + cTitulo + ".xls" )
    oExcelApp:SetVisible(.T.)
endif

Return

//-----------------------------------
// Tela de Log
//-----------------------------------
Static Function MostraLog(cLog)

Local oDlg
Local cMemo
Local cFile    :=""
Local cMask    := "Arquivos Texto (*.TXT) |*.txt|"
Local oFont 

//DEFINE FONT oFont NAME "Arial" SIZE 7,14   //6,15

DEFINE MSDIALOG oDlg TITLE "Log de Processamento" From 3,0 to 340,550 PIXEL

@ 5,5 GET oMemo  VAR cLog MEMO SIZE 267,145 OF oDlg PIXEL 
oMemo:bRClicked := {||AllwaysTrue()}
//oMemo:oFont:=oFont

DEFINE SBUTTON  FROM 153,230 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER
                                
Return    
