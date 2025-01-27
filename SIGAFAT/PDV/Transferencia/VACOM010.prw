#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#include 'topconn.ch'
#INCLUDE "TBICODE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc}  VACOM010
Tela Conferencia Cega

@author Eduardo Patriani
@since 11/05/2018
@version 1.0

/*/
User Function VACOM010()
Local aArea	  			:= GetArea()
Local lRet 				:= .T.
Local cCadastro 		:= "Conferência Cega"
Local cDoc 				:= F1_DOC
Local cSerie 			:= F1_SERIE
Local cFornece			:= F1_FORNECE
Local cLoja				:= F1_LOJA
Local cChave 			:= ""
Local nOpca				:= 0
Local aSize 			:= MsAdvSize()
Local cConf				:= ""
Local oFnt
Local oFnt1

Private oOpera
Private cOpera      	:= CriaVar('CB1_CODOPE',.T.)
Private oChave
Private cChave			:= BuscaChvNf() //Space(44)
Private oProduto
Private cProduto 		:= CriaVar("B1_COD",.F.)
Private oArmazem
Private cArmazem		:= "01"   //CriaVar("B1_LOCPAD",.F.)
//Private aAlter  		:= {"QTD","OBS"}
Private aAlter  		:= {"OBS"}
Private aHeaderGrd2 	:= {}
Private aColsGrd2 		:= {}
Private aButtons 		:= {}
Private oOk	 			:= LoadBitMap(GetResources(), "BR_VERDE")
Private oNo	 			:= LoadBitMap(GetResources(), "BR_VERMELHO")
Private oPc	 			:= LoadBitMap(GetResources(), "BR_AZUL")
Private oLayer
Private oGetGrade
Private cCodLin
Private oLinha
Private oColuna
Private lConf 			:= .T.
Private	 lRetorno		:= .T.
Private oNome
Private cNomeConf 		:= CriaVar('CB1_NOME',.T.)

aAdd(aButtons, {'BMPINCLUIR', {|| U_VACOM020() }, "Operadores"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a fonte da tela.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFnt 	NAME "TAHOMA" SIZE 0,-11 BOLD
DEFINE FONT oFnt1 	NAME "TAHOMA"	SIZE 0,-16 BOLD

lRetorno := CA025ATU(cDoc,cSerie,cFornece,cLoja,@aHeaderGrd2,@aColsGrd2)

if lRetorno
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estancia Objeto FWLayer. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLayer := FWLayer():new()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o objeto com a janela que ele pertencera. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLayer:init(oDlg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Linha do Layer. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLayer:addLine('Lin01',030,.F.)
	oLayer:addLine('Lin10',070,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a coluna do Layer. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLayer:addCollumn('Col01',050,.F.,'Lin01')
	oLayer:addCollumn('Col02',050,.F.,'Lin01')
	oLayer:addCollumn('Col10',100,.F.,'Lin10')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona Janelas as suas respectivas Colunas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLayer:addWindow('Col01','L1_Win01','Dados NF'	,100,.T.,.F.,,'Lin01',)
	oLayer:addWindow('Col02','L1_Win01','Produto'		,100,.T.,.F.,,'Lin01',)
	oLayer:addWindow('Col10','L1_Win10','Itens'		,100,.T.,.F.,,'Lin10',)

	DEFINE FONT oFont16N NAME "Arial" SIZE 0,-16 BOLD

	@ 004,010 SAY "Documento:"	OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 040,010
	@ 003,050 MSGET oDoc VAR cDoc PICTURE PesqPict('SF1','F1_DOC') WHEN .F. OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 050,010 NO MODIFY

	@ 004,120 SAY "Serie:"		OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 040,010
	@ 003,140 MSGET oSerie VAR cSerie PICTURE PesqPict('SF1','F1_SERIE') WHEN .F. OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 035,010 NO MODIFY

	@ 023,010 SAY "Conferente:"	OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 040,010
	@ 022,050 MSGET oOpera VAR cOpera PICTURE PesqPict('CB1','CB1_CODOPE') F3 "CB1" WHEN .T. OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 035,010 VALID ExistCpo("CB1",&(ReadVar())) .AND. CA025NOM(cOpera)
	@ 022,085 MSGET oNome VAR cNomeConf PICTURE PesqPict('CB1','CB1_NOME') WHEN .T. OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 070,010 NO MODIFY

	@ 040,010 SAY "Chave NF:"	OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 040,010
	@ 038,050 MSGET oChave VAR cChave PICTURE PesqPict('SF1','F1_CHVNFE') VALID EmBranco(cChave) WHEN .F. OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') PIXEL SIZE 180,010

	@ 010,010 SAY "Informe o Produto" Of oLayer:getWinPanel('Col02','L1_Win01','Lin01') FONT oFnt1 COLOR CLR_BLUE Pixel SIZE 120,10
	//@ 025,010 MSGET oProduto VAR cProduto Of oLayer:getWinPanel('Col02','L1_Win01','Lin01') PICTURE PesqPict("SB1","B1_COD") VALID ( Vazio() .OR. If(NaoVazio(),( ExistCpo("SB1",cProduto) , BuscaSB1(@oProduto,@cProduto,oGetGrade) ),CriaVar("B1_COD",.F.))  ) F3 "SB1" FONT oFnt1 COLOR CLR_BLACK SIZE 100,20 Pixel
	@ 025,010 MSGET oProduto VAR cProduto Of oLayer:getWinPanel('Col02','L1_Win01','Lin01') PICTURE PesqPict("SB1","B1_COD") ;
			  VALID BuscaSB1(@oProduto,@cProduto,oGetGrade)  F3 "SB1" FONT oFnt1 COLOR CLR_BLACK SIZE 100,20 Pixel

	@ 010,120 SAY "Informe o Armazem" Of oLayer:getWinPanel('Col02','L1_Win01','Lin01') FONT oFnt1 COLOR CLR_BLUE Pixel SIZE 120,10
	@ 025,120 MSGET oArmazem VAR cArmazem Of oLayer:getWinPanel('Col02','L1_Win01','Lin01') PICTURE PesqPict("SB1","B1_LOCPAD") ;
			  VALID ( Vazio() .OR. ( ExistCpo("NNR") .and. A010VLoc() )) F3 "NNR" FONT oFnt1 COLOR CLR_BLACK SIZE 40,20 Pixel

	//oGetGrade:=MsNewGetDados():New(1,1,1,1,GD_UPDATE,,,"MAREF",aAlter,,999,,,,oLayer:getWinPanel('Col10','L1_Win10','Lin10'),@aHeaderGrd2,@aColsGrd2)
	//oGetGrade:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetGrade:=MsNewGetDados():New(1,1,155,495,GD_UPDATE,,,"MAREF",aAlter,,999,,,,oLayer:getWinPanel('Col10','L1_Win10','Lin10'),@aHeaderGrd2,@aColsGrd2)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , { || IIF(lConf,IIF( CA025FIM(oGetGrade:aCols,cOpera,cDoc,cSerie,cFornece,cLoja,cConf,cChave), oDlg:End(), .F.),oDlg:End()) } , { || oDlg:End() },,aButtons) CENTERED
endif

RestArea(aArea)

RETURN

/*/{Protheus.doc}  CA025ATU
Cabecalho e Itens


@author Eduardo Patriani
@since 14/05/2014
@version 1.0

/*/
Static Function CA025ATU(cDoc,cSerie,cFornece,cLoja,aHeaderGrd2,aColsGrd2)
Local aArea	:= GetArea()
Local lRet  := .T.

IF !EMPTY(SF1->F1_STATUS)
	MSGINFO("Documento já classificado!!","Atenção")
	lConf     := .F.
	Return(lConf)
ENDIF

aHeaderGrd2 := {}
aColsGrd2   := {}

Aadd(aHeaderGrd2,{''                    ,'OK'       ,'@BMP'                         ,01                         ,0,'.F.'                ,'?','C',''         ,'' } )
Aadd(aHeaderGrd2,{"Item NF"             ,'ITEM'     ,PESQPICT("SD1","D1_ITEM")      ,TamSX3('D1_ITEM')[1]       ,0,'.F.'                ,'û','C',''         ,'' } )
Aadd(aHeaderGrd2,{"Cod. Produto"        ,'COD'      ,'@!'                           ,15                         ,0,'.F.'                ,'û','C',''         ,'' } )
Aadd(aHeaderGrd2,{"Código de Barras"    ,'CODBAR'   ,PESQPICT("SB1","B1_CODBAR")    ,TamSX3('B1_CODBAR')[1]     ,0,'.F.'                ,'û','C',''         ,'' } )
Aadd(aHeaderGrd2,{"Descrição"           ,'DESC'     ,'@!'                           ,30                         ,0,'.F.'                ,'û','C',''         ,'' } )
Aadd(aHeaderGrd2,{"Pedido Compra"       ,'PEDI'     ,'@!'                           ,15                         ,0,'.F.'                ,'û','C',''         ,'' } )
Aadd(aHeaderGrd2,{"Qtde. Conf"          ,'QTD'      ,PESQPICT("SD1","D1_QUANT")     ,TamSX3('D1_QUANT')[1]      ,0,'U_CA025VALID()'     ,'û','N',''         ,'' } )
Aadd(aHeaderGrd2,{"Saldo a Conf"        ,'SLD'      ,PESQPICT("SD1","D1_QUANT")     ,TamSX3('D1_QUANT')[1]      ,0,'U_CA025VALID()'     ,'û','N',''         ,'' } )
Aadd(aHeaderGrd2,{"Obs. Pedido"         ,'OBSPV'    ,PESQPICT("SC7","C7_OBS")       ,TamSX3('C7_OBS')[1]        ,0,'.T.'                ,'û','C',''         ,'' } )
Aadd(aHeaderGrd2,{"Obs. Conferencia"    ,'OBS'      ,PESQPICT("SC7","C7_OBS")       ,TamSX3('C7_OBS')[1]        ,0,'.T.'                ,'û','C',''         ,'' } )

DBSELECTAREA("PC2")
DBSETORDER(1)

IF lConf
	IF DBSEEK(xFilial("PC2")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		IF MSGYESNO("Conferência Cega já efetuada, deseja inserir novamente?","Atenção")
			lConf := .T.
		ELSE
			lConf     := .F.
			aAlter    := {}
			cOpera 	  := PC2->PC2_CONFER
			cNomeConf := POSICIONE("CB1",1, xFilial("CB1")+alltrim(PC2->PC2_CONFER),"CB1_NOME")
		ENDIF
	endif
else
	IF DBSEEK(xFilial("PC2")+SF1->F1_DOC+SF1->F1_SERIE)
		lConf     := .F.
		aAlter    := {}
		cOpera 	  := PC2->PC2_CONFER
		cNomeConf := POSICIONE("CB1",1, xFilial("CB1")+alltrim(PC2->PC2_CONFER),"CB1_NOME")
	endif
endif

DBSELECTAREA("SD1")
DBSETORDER(1)

If DBSEEK(xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While SF1->(!Eof()) .AND. ALLTRIM(SD1->D1_DOC) == ALLTRIM(SF1->F1_DOC) .AND. ALLTRIM(SD1->D1_SERIE) == ALLTRIM(SF1->F1_SERIE) .AND. ;
				ALLTRIM(SF1->F1_FORNECE) == ALLTRIM(SD1->D1_FORNECE) .AND. ALLTRIM(SF1->F1_LOJA) == ALLTRIM(SD1->D1_LOJA)

		aadd(aColsGrd2,{;
		oNo,;
		ALLTRIM(SD1->D1_ITEM),;
		ALLTRIM(SD1->D1_COD),;
		POSICIONE("SB1",1,xFilial("SB1")+ALLTRIM(SD1->D1_COD),"B1_CODBAR"),;
		POSICIONE("SB1",1,xFilial("SB1")+ALLTRIM(SD1->D1_COD),"B1_DESC"),;
		ALLTRIM(SD1->D1_PEDIDO),;
		IIF(lConf,0,POSICIONE("PC2",1,xFilial("PC2")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM,"PC2_QTDCON")),;
		SD1->D1_QUANT-POSICIONE("PC2",1,xFilial("PC2")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM,"PC2_QTDCON"),;
		POSICIONE("SC7",1,xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC,"C7_OBS"),;
		POSICIONE("PC2",1,xFilial("PC2")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM,"PC2_OBS"),;
		.F.})

		SD1->(DbSkip())
	Enddo
EndIf

If Len(aColsGrd2) == 0
	aadd(aColsGrd2,{oNo,"","","","","","","","","","",.F.})
Endif

RestArea(aArea)

return(lRet)

/*/{Protheus.doc}  CA025VALID
Validação Campo Quantidade


@author Eduardo Patriani
@since 11/05/2018
@version 1.0

/*/
User Function CA025VALID()
Local aArea	:= GetArea()
Local lRet 	:= .T.

//Validação Quantidade
IF M->QTD < 0
	FwAlertError("Quantidade informada está incorreta")
	lRet := .F.
ElseIf M->SLD = 0
	FwAlertWarning("Não há mais saldo para este produto")
	lRet := .F.
ENDIF

RestArea(aArea)
RETURN(lRet)

/*/{Protheus.doc}  CA025FIM
Confirmação tela Conferência Cega


@author Eduardo Patriani
@since 11/05/2018
@version 1.0

/*/
STATIC FUNCTION CA025FIM(aCols,cOpera,cDoc,cSerie,cFornece,cLoja,cConf,cChave)

Local lRet 	:= .T.
Local nX   	:= 1
Local aDiverg := {}

//Verifica Operador
IF EMPTY(cOpera)
	FwAlertInfo("Operador não informado.")
	//MSGINFO("Operador não informado.")
	lRet := .F.
ENDIF

BEGIN TRANSACTION

IF lRet
	DBSELECTAREA("PC2")
	DbSetOrder(1)
	
	IF DBSEEK(xFilial("PC2")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		while PC2->(!Eof()) .AND. ALLTRIM(PC2->PC2_DOC) == ALLTRIM(SF1->F1_DOC) .AND. ALLTRIM(PC2->PC2_SERIE) == ALLTRIM(SF1->F1_SERIE);
			.AND. ALLTRIM(SF1->F1_FORNECE) == ALLTRIM(PC2->PC2_FORNEC) .AND. ALLTRIM(SF1->F1_LOJA) == ALLTRIM(PC2->PC2_LOJA)
			PC2->(RecLock("PC2",.F.))
			PC2->(DBDelete())
			PC2->(DbSkip())
			PC2->(MsUnLock())
		ENDDO
	ENDIF
	
	FOR nX := 1 to len(aCols)
		nQtdOri := POSICIONE("SD1",dbNickOrder( "SD1","VACOM010"),xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nX][2],"D1_QUANT")
		IF !(nQtdOri == aCols[nX][7])
			aadd(aDiverg,{aCols[nX][2],aCols[nX][3],aCols[nX][4],Transform(aCols[nX][7],'@E 9,999.99')})
		endif
		
		DbSelectArea("PC2")
		RecLock("PC2",.T.)
		
		PC2_FILIAL := xFilial("PC2")
		PC2_DOC    := ALLTRIM(cDoc)
		PC2_SERIE  := ALLTRIM(cSerie)
		PC2_FORNEC := ALLTRIM(cFornece)
		PC2_LOJA   := ALLTRIM(cLoja)
		PC2_ITEM   := aCols[nX][2]
		PC2_COD    := aCols[nX][3]
		PC2_QTDORI := nQtdOri
		PC2_QTDCON := aCols[nX][7]
		PC2_CONFER := cOpera
		PC2_OPERAD := __cUserId
		PC2_DATA   := dDataBase
		PC2_HORA   := SUBSTR(TIME(),1,5)
		PC2_OBS    := aCols[nX][9]
		
		PC2->(MsUnLock())
	next nX
	
	IF !EMPTY(aDiverg)
		cConf := "N"
	Else
		cConf := "S"
	EndIf
	
	DBSELECTAREA("SF1")
	DBSETORDER(1)
	IF DBSEEK(xFilial("SF1")+AvKey(cDoc,"F1_DOC")+AvKey(cSerie,"F1_SERIE")+AvKey(cFornece,"F1_FORNECE")+AvKey(cLoja,"F1_LOJA"))
		SF1->(RecLock("SF1",.F.))
		F1_XCONF := cConf//"S"
		F1_CHVNFE := cChave
		SF1->(MsUnLock())
	ENDIF
endif

IF !EMPTY(aDiverg)
	CA025DIV(aDiverg)
endif

//----------------------------------------------------------------------------------------
// Classificação da NF
//----------------------------------------------------------------------------------------
If SF1->F1_XCONF == "S"
	LjMsgRun("Por favor aguarde, classificando NF...", , { || VAM010NFiscal() } )
endif

END TRANSACTION

RETURN(lRet)

/*/{Protheus.doc}  CA025NOM
Gatilho Nome Operador


@author Eduardo Patriani
@since 11/05/2018
@version 1.0

/*/
Static Function CA025NOM(cOpera)

cNomeConf := POSICIONE( "CB1", 1, xFilial("CB1")+alltrim(cOpera),"CB1_NOME")

RETURN(.T.)

Static Function CA025DIV(aDiverg)

Local aAreaAtu 		:= GetArea()
Local aColsDistrib 	:= {}
Local oDlg1
Local cCadastro := "Divergencia Conferencia Cega"
Local lOk := .F.
Local oBrowse

IF EMPTY(aDiverg)
	aadd(aDiverg,{"","","",""})
ENDIF

Aviso( 	"VACOM010",;
"Atenção: Conferencia Cega Encontrou Divergencia. " + CHR(13)+CHR(10) +;
"Caso seja dado entrada na nota, será necessário gerar devolução. ", { "OK" }, 2 )

DEFINE MSDIALOG oDlg1 TITLE cCadastro FROM 0,0 TO 400,800 Of oMainWnd PIXEL

oPanel:= TPanel():New(0, 0, "", oDlg1, NIL, .T., .F., NIL, NIL, 0,96, .T., .F. )
oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

DEFINE FWBROWSE oBrowse DATA ARRAY ARRAY aDiverg OF oPanel

//-------------------------------------------------------------------
// Adiciona as colunas do Browse
//-------------------------------------------------------------------
ADD COLUMN oColumn DATA { || aDiverg[oBrowse:nAt][01]	} TITLE "Item"				ALIGN CONTROL_ALIGN_LEFT SIZE 5 OF oBrowse
ADD COLUMN oColumn DATA { || aDiverg[oBrowse:nAt][02]	} TITLE "Cod. Produto"	  	ALIGN CONTROL_ALIGN_LEFT SIZE 1 OF oBrowse
ADD COLUMN oColumn DATA { || aDiverg[oBrowse:nAt][03]	} TITLE "Ref. Fornecedor"	ALIGN CONTROL_ALIGN_LEFT SIZE 1 OF oBrowse
ADD COLUMN oColumn DATA { || aDiverg[oBrowse:nAt][04]	} TITLE "Qtd. Conferida"	ALIGN CONTROL_ALIGN_LEFT SIZE 1 OF oBrowse

oBrowse:DisableConfig()
oBrowse:DisableSeek()
oBrowse:DisableFilter()
oBrowse:Refresh()

ACTIVATE FWBROWSE oBrowse

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar( oDlg1 , { || lOk := .T. , oDlg1:End(), oDlg1:End() } , { || oDlg1:End() } ) CENTERED

Return
/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 16/05/2019
@Hora: 13:27:44
@Versão: 1.0
@Uso:
@Descrição:
---------------------------------------------
Change:
--------------------------------------------*/
Static Function VAM010NFiscal()

Local aArea    	:= GetArea()
Local aCab     	:= {}
Local aItens   	:= {}
Local aLinha   	:= {}
Local cTES		:= "" //GetMv("VA_TESTRENT",,"076")

aCab := {}
Aadd( aCab, { "F1_FILIAL"  	, SF1->F1_FILIAL , Nil } )
Aadd( aCab, { "F1_TIPO"  	, SF1->F1_TIPO   , Nil } )
Aadd( aCab, { "F1_FORMUL"	, SF1->F1_FORMUL , Nil } )
Aadd( aCab, { "F1_DOC"   	, SF1->F1_DOC    , Nil } )
Aadd( aCab, { "F1_SERIE" 	, SF1->F1_SERIE  , Nil } )
Aadd( aCab, { "F1_EMISSAO" 	, SF1->F1_EMISSAO, Nil } )
Aadd( aCab, { "F1_FORNECE"	, SF1->F1_FORNECE, Nil } )
Aadd( aCab, { "F1_LOJA"  	, SF1->F1_LOJA   , Nil } )
Aadd( aCab, { "F1_ESPECIE"	, SF1->F1_ESPECIE, Nil } )
Aadd( aCab, { "F1_CHVNFE"	, SF1->F1_CHVNFE , Nil } )
Aadd( aCab, { "F1_COND"  	, SF1->F1_COND   , Nil } )
//Aadd( aCab, { "F1_STATUS"  	, "A"            , Nil } )

// AJUSTE SERGIO JUNIOR - 05/09/2019

/*
DbSelectArea("SD1")
DbSetOrder(1)
DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA	)
While SD1->(!EOF()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
*/

cQry	:= " SELECT * "
cQry	+= " FROM "+RetSqlName("SD1")+ " SD1 "
cQry	+= " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
cQry	+= " AND D1_DOC = '"+SF1->F1_DOC+"' "
cQry	+= " AND D1_SERIE = '"+SF1->F1_SERIE+"' "
cQry	+= " AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "
cQry	+= " AND D1_LOJA = '"+SF1->F1_LOJA+"' "
cQry	+= " AND SD1.D_E_L_E_T_ = '' "

If Select("XXX") > 0
	XXX->(dbCloseArea())
EndIf

dbUseArea(.T.,"TObPCONN",TcGenQry(,,cQry),"XXX",.F.,.T.)

While XXX->(!EOF())
	
	cTes := ""
	xNCM := Posicione("SB1",1,xFilial("SB1")+XXX->D1_COD,"B1_POSIPI")

	// Verificar se e nota de transferencia entre filiais (sem IPI)	ou da matriz para filial (com IPI)
	If TransfFil() .or. Posicione("SB1",1,xFilial("SB1")+XXX->D1_COD,"B1_IPI") = 0
		cTes := SuperGetMV("VA_TESSIPI",.F.,"084")
	Else
		cTes := SuperGetMV("VA_TESCIPI",.F.,"101")
	EndIf
/*	IF Alltrim (xNCM) $ '33030010|33030020' .AND. Posicione("SM0",1,"2H"+SUBSTR(SF1->F1_01OST,7,2),"M0_ESTCOB") == Posicione("SM0",1,"2H"+cFilAnt,"M0_ESTCOB")
		cTes := GetMv("VA_TESPERF",,"102")
	Else
		If SUBSTR(SF1->F1_01OST,7,2)=='00' .OR. EMPTY(SF1->F1_01OST)
			If EMPTY(XXX->D1_XPVEND)
				cTes := GetMv("VA_TESCIPI",,"101")
			Else
				cTes := GetMv("VA_TESSIPI",,"084")
			EndIf
		Else
			cTes := GetMv("VA_TESSIPI",,"084")
		EndIf
	EndIf */
	
	aLinha := {}
	Aadd( aLinha, { "D1_FILIAL"    	, XXX->D1_FILIAL	, Nil } )
	Aadd( aLinha, { "D1_ITEM"    	, XXX->D1_ITEM 		, Nil } )
	Aadd( aLinha, { "D1_COD"    	, XXX->D1_COD  		, Nil } )
	Aadd( aLinha, { "D1_QUANT"  	, XXX->D1_QUANT		, Nil } )
	Aadd( aLinha, { "D1_VUNIT"  	, XXX->D1_VUNIT		, Nil } )
	Aadd( aLinha, { "D1_TOTAL"  	, XXX->D1_TOTAL 	, Nil } )
	//Aadd( aLinha, { "D1_LOCAL"  	, XXX->D1_LOCAL  	, Nil } )
	Aadd( aLinha, { "D1_LOCAL"  	, cArmazem		  	, Nil } )
	//Aadd( aLinha, { "D1_CUSTO"  	, XXX->D1_VUNIT  	, Nil } )  // AJUSTE SERGIO JUNIOR
	Aadd( aLinha, { "D1_BASEIPI"  	, XXX->D1_BASEIPI  	, Nil } )  // AJUSTE SERGIO JUNIOR
	Aadd( aLinha, { "D1_TES" 		, cTES 				, Nil } )
	Aadd( aLinha, { "D1_TESACLA"	, cTES 				, Nil } )
	Aadd( aLinha, { "D1_UM"    		, XXX->D1_UM		, Nil } )
	Aadd( aLinha, { "D1_XPVEND" 	, 'N'				, Nil } )
	Aadd( aItens, aLinha)

	XXX->(DbSkip())
	
	// FIM AJUSTE SERGIO JUNIOR
	
EndDo
Varinfo("Conteudo aItens", aItens)
if Len(aItens) > 0
	
	U_ClasM103(cEmpAnt,cFilAnt,aCab,aItens) 
	//StartJob('U_ClasM103',getEnvServer(),.F.,cEmpAnt,cFilAnt,aCab,aItens) //U_ExcM103(cEmpAnt,cFilAnt,aCab,aItens) 
	//aRet := StartJob('U_ClasM103',getEnvServer(),.F.,cEmpAnt,cFilAnt,aCab,aItens) //U_ExcM103(cEmpAnt,cFilAnt,aCab,aItens) 
	//If !aRet[1]
	//	Conout(aRet[2])
	//	MsgAlert(aRet[2])
	//Endif
	
	Sleep(10000)
	//A103NFiscal('SF1',SF1->(Recno()),4,.F.,.F.)
	
endif

RestArea(aArea)

Return(.T.)

//----------------------------------------------------
// 
//----------------------------------------------------
User Function ClasM103(cXEmpresa,cXFilial,aCab,aItens)

Local lRet := .T.
Local cMsg := ""

Conout("mau1")
//PREPARE ENVIRONMENT EMPRESA cXEmpresa FILIAL cXFilial
//RpcSetType(3)
//RpcSetEnv(cXEmpresa,cXFilial,,,"COM",GetEnvServer(),{"SB1","SF1","SD1"})

Private lMSHelpAuto := .T.
Private lMsErroAuto := .F.

Conout("mau2")
Conout("mau acab "+cValtoChar(Len(aCab)))
Conout("mau aItens "+cValtoChar(Len(aItens)))
MsExecAuto({|x,y,z| Mata103(x,y,z)},aCab,aItens,4)
	
IF lMsErroAuto

Conout("mau3")
	MostraErro()
	lRet := .F.
	cMsg := MostraErro()

EndIF

//RESET ENVIRONMENT
//RpcClearEnv()

Return({lRet,cMsg})

/*--------------------------------------------
@Autor: Sergio Junior
@Data: 21/10/2019
@Hora: 23:08:00
@Versão: 1.0
@Uso:
@Descrição:
---------------------------------------------
Change:
--------------------------------------------*/
Static Function EmBranco(cChave)

If Empty(cChave)
	Return .F.
Else
	Return .T.
EndIf

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 06/06/2019
@Hora: 10:53:47
@Versão: 1.0
@Uso:
@Descrição:
---------------------------------------------
Change:
--------------------------------------------*/
Static Function BuscaSB1(oProduto,cProduto,oGetGrade)

Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->( GetArea() )
Local aAreaSF1 := SF1->( GetArea() )
Local nPosItem := Ascan(oGetGrade:aHeader,{|x| x[2] == "ITEM"	})
Local nPosProd := Ascan(oGetGrade:aHeader,{|x| x[2] == "COD"	})
Local nPosQtde := Ascan(oGetGrade:aHeader,{|x| x[2] == "QTD"	})
Local nPosSald := Ascan(oGetGrade:aHeader,{|x| x[2] == "SLD"	})
Local lAchou   := .F.
Local nX       := 0
Local nQtdOri  := 0

If Empty(cProduto)
	Return Nil
EndIf

SB1->(dBSetOrder(1))  // B1_FILIAL+B1_COD
If SB1->(MsSeek(xFilial("SB1")+cProduto))
	For nX := 1 To Len(oGetGrade:aCols)
		if Alltrim(oGetGrade:aCols[nX][nPosProd]) == Alltrim(cProduto)
			If oGetGrade:aCols[nX,nPosSald] = 0
				If nX = Len(oGetGrade:aCols) .or. aScan(oGetGrade:aCols,{|x| Alltrim(x[nPosProd]) == Alltrim(cProduto)},nX+1) = 0
					FwAlertError("Produto sem saldo para conferência")
					lAchou := .T.
					Exit
				EndIf
			Else
				oGetGrade:aCols[nX,nPosQtde]++
				oGetGrade:aCols[nX,nPosSald]--
				IF oGetGrade:aCols[nX,nPosSald] = 0
					oGetGrade:aCols[nX][1] := oOk
				Else
					oGetGrade:aCols[nX][1] := oPc
				endif

				lAchou := .T.
				Exit
			EndIf

	/*		
			if oGetGrade:aCols[nX][nPosQtde] == 0
				
				oGetGrade:aCols[nX][nPosQtde] := 1
				
				nQtdOri := POSICIONE("SD1",dbNickOrder( "SD1","VACOM010"),xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+oGetGrade:aCols[nX][nPosItem],"D1_QUANT")
				IF (nQtdOri == oGetGrade:aCols[nX][nPosQtde])
					oGetGrade:aCols[nX][1] := oOk
					lAchou := .T.
					Exit
				endif
				
			endif
	*/
		endif
	Next

	if !lAchou
		FwAlertWarning("O Produto: "+cProduto+" não foi encontrado na Nota Fiscal")
		/*Aviso( 	"VACOM010",;
		"Atenção, O Produto: "+cProduto+" não foi encontrado na Nota Fiscal. " + CHR(13)+CHR(10) +;
		"Informe outro produto. ", { "OK" }, 2 )*/
	Else
		oGetGrade:GoTo(nX)
	Endif

	oGetGrade:oBrowse:Refresh()
	oGetGrade:Refresh()

	cProduto:=CriaVar("B1_COD",.F.)
	oProduto:SetFocus()
	oProduto:Refresh()
Else
	FwAlertError("Produto "+cProduto+" não cadastrado")
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSF1)
RestArea(aAreaAnt)

Return Nil
/*----------------------------------------------------------------------------*
* Funcao para buscar a chave da nota fiscal na filial de origem               *
* TOTVS IP    16/03/2023                                                      *
*-----------------------------------------------------------------------------*/
Static Function BuscaChvNf()
Local aAreaAnt := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaSF2 := SF2->(GetArea())
Local cChvNfe := Space(44)
Local aFiliais := FWLoadSM0()  //FWSM0Util():GetSM0Data()

SA2->(dBSetOrder(1))  // A2_FILIAL+A2_COD+A2_LOJA
SF2->(dBSetOrder(1))  // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

If SA2->(MsSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
	nPos := aScan(aFiliais,{|x| x[18] = SA2->A2_CGC})
	If nPos > 0 .and. SF2->(MsSeek(aFiliais[nPos,2]+SF1->(F1_DOC+F1_SERIE)))
		cChvNfe := SF2->F2_CHVNFE
	EndIf
EndIf

RestArea(aAreaSF2)
RestArea(aAreaSA2)
RestArea(aAreaAnt)

Return cChvNfe
/*----------------------------------------------------------------------------*
* Funcao para verificar se e nota de transferencia entre filiais ou da matriz *
* para a filial                                                               *
* TOTVS IP    16/03/2023                                                      *
*-----------------------------------------------------------------------------*/
Static Function TransfFil()
Local aAreaAnt := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local lRet := .F.
Local aFiliais := FWLoadSM0()  //FWSM0Util():GetSM0Data()

SA2->(dBSetOrder(1))  // A2_FILIAL+A2_COD+A2_LOJA

If SA2->(MsSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
	nPos := aScan(aFiliais,{|x| x[18] = SA2->A2_CGC})
	If nPos > 0 .and. Alltrim(aFiliais[nPos,2]) <> "00"
		lRet := .T.
	EndIf
EndIf

RestArea(aAreaSA2)
RestArea(aAreaAnt)

Return lRet
