#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "Jpeg.ch"
#INCLUDE "MsmGadd.ch"
//#Include "InKey.ch"
#Include "vKey.ch"

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 07/05/2019
@Hora: 11:04:02
@Versão: 1.0
@Uso: 
@Descrição: Rotina para transferencia de 
mercadorias com geração do pedido de venda
--------------------------------------------*/
User Function VAFAT010()

Private ACOLTRFEXC := {}
Private L410AUTO := .F.

	//Browser do pedido de venda
	VABRWSC5()

Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 12/07/2019
@Hora: 12:08:16
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Função para criação da 
transferencia de mercadoria. 
--------------------------------------------*/
User Function VACRIATR()

Local aArea	 	:= GetArea()
Local cCliente   	:= CriaVar("A1_COD",.F.)
Local cLojaCli		:= CriaVar("A1_LOJA",.F.)
Local cNomeCli		:= CriaVar("A1_NREDUZ",.F.)
Local aSize    	:= MsAdvSize()
Local lConfirma 	:= .F.
Local aOperacao	:= {'1=Transferencia','2=Demonstração'}
Local oOperacao
Local oCliente
Local oLojaCli
Local oNomeCli
Local oDlg
Local oSL1
Local oSL2
Local oFnt
Local aBoxParam 	:= {}
Local aRetParam  	:= {}
Local nRecno		:= 0

Private cProduto 	:= CriaVar("B1_COD",.F.)     
Private cArmazem 	:= "01" //CriaVar("NNR_CODIGO",.F.)     
Private cOperacao	:= ""
Private cConsPad	:= ""
Private cNumPed	:= ""
Private nTotProd	:= 0
Private nTotQtd	:= 0
Private nPosProd	:= 0
Private nPosDesc	:= 0
Private nPosUM		:= 0
Private nPosCodB	:= 0
Private nPosQtde	:= 0
Private nPosNcm	:= 0
Private nPosLoc	:= 0
Private nPosCusto	:= 0
Private nPosVazio	:= 0
Private oMainWnd
Private oGetGrade
Private oTotProd
Private oTotQtd
Private oProduto   
Private oArmazem   

Private aCabecIte 	:= {}
Private aDadosIte 	:= {}
Private aAlter			:= {}

Private bRefresh		:= {|| AtuRodape(@cProduto,@oProduto,@nTotProd,@oTotProd,@nTotQtd,@oTotQtd,@oGetGrade) }

Aadd(aBoxParam,{3,"Operação",1,aOperacao,100,,.T.})

IF !ParamBox(aBoxParam,"Informe os Parâmetros",@aRetParam,,,,,,,,.F.) // 
	Return(.F.)
else
	cConsPad 	:= if(aRetParam[1]==1,"SA1TRA","SA1")
	cOperacao 	:= if(aRetParam[1]==1,"1","2")
EndIf

//----------------------------------------------------------------------------------------
// Monta aHeader e aCols do produto
//----------------------------------------------------------------------------------------
MntaHeader(@aCabecIte,@aDadosIte)

nPosProd	:= Ascan(aCabecIte,{|x| x[2] == "PRODUTO"})
nPosDesc	:= Ascan(aCabecIte,{|x| x[2] == "DESCRI"})
nPosUM		:= Ascan(aCabecIte,{|x| x[2] == "UM"})
nPosCodB	:= Ascan(aCabecIte,{|x| x[2] == "CODBAR"})
nPosQtde	:= Ascan(aCabecIte,{|x| x[2] == "QTDVEN"})
nPosNcm		:= Ascan(aCabecIte,{|x| x[2] == "POSIPI"})
nPosLoc		:= Ascan(aCabecIte,{|x| x[2] == "LOCAL"	})
nPosCusto	:= Ascan(aCabecIte,{|x| x[2] == "CUSTO"})
nPosVazio	:= Ascan(aCabecIte,{|x| x[2] == "FLAG"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a fonte da tela.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFnt 	NAME "TAHOMA" SIZE 0,-11 BOLD
DEFINE FONT oFnt1 NAME "TAHOMA"	SIZE 0,-16 BOLD

DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[6],aSize[5] TITLE "Transferência de mercadorias" Of oMainWnd PIXEL

oDlg:lEscClose := .F.

oLayer:= FWLayer():new()
oLayer:init(oDlg,.F.)
oLayer:addLine('Lin01',97,.F.)
oLayer:addCollumn('Col01',100,.F.,'Lin01')
oLayer:addWindow('Col01','L1_Win01','Dados do cliente'	,25,.F.,.F.,,'Lin01',)
oLayer:addWindow('Col01','L2_Win01','Dados do Produto'	,52,.F.,.F.,,'Lin01',)
oLayer:addWindow('Col01','L3_Win01','Totalizadores'		,15,.F.,.F.,,'Lin01',)

@ 08,010 SAY "Loja Destino: " Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') FONT oFnt COLOR CLR_BLUE Pixel SIZE 60,10
@ 05,056 MSGET oCliente VAR cCliente Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') PICTURE PesqPict("SA1","A1_COD") VALID ( ExistCpo("SA1",cCliente) .And. RetNomCli(@oNomeCli,@cNomeCli,cCliente,cLojaCli,@oProduto,"N") ) F3 cConsPad FONT oFnt COLOR CLR_BLACK SIZE 40,10 Pixel
@ 05,096 MSGET oLojaCli VAR cLojaCli Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') PICTURE PesqPict("SA1","A1_LOJA") VALID ( ExistCpo("SA1",cCliente) .And. RetNomCli(@oNomeCli,@cNomeCli,cCliente,cLojaCli,@oProduto,"S") ) FONT oFnt COLOR CLR_BLACK SIZE 20,10 Pixel
@ 05,116 MSGET oNomeCli VAR cNomeCli Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') PICTURE PesqPict("SA1","A1_NREDUZ") WHEN .F. FONT oFnt COLOR CLR_BLACK SIZE 80,10 Pixel

@ 08,230 SAY "Operação" OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') FONT oFnt1 COLOR CLR_BLUE Pixel SIZE 50,10
@ 07,275 COMBOBOX oOperacao VAR cOperacao ITEMS aOperacao OF oLayer:getWinPanel('Col01','L1_Win01','Lin01') WHEN .F. FONT oFnt1 COLOR CLR_BLACK SIZE 80,10 Pixel

@ 30,010 SAY "Armazém: " Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') FONT oFnt1 COLOR CLR_BLUE Pixel SIZE 60,10
@ 28,056 MSGET oArmazem VAR cArmazem Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') PICTURE PesqPict("NNR","NNR_CODIGO") VALID If(!Empty(cArmazem),VLDARMZ(@cArmazem,@oProduto,@cProduto,aCabecIte),) F3 "NNR" FONT oFnt1 COLOR CLR_BLACK SIZE 15,10 Pixel

@ 30,230 SAY "Produto: " Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') FONT oFnt1 COLOR CLR_BLUE Pixel SIZE 60,10
@ 28,275 MSGET oProduto VAR cProduto Of oLayer:getWinPanel('Col01','L1_Win01','Lin01') PICTURE PesqPict("SB1","B1_COD") VALID Vazio() .OR. If(NaoVazio(), /*ExistCpo("SB1",cProduto)*/VLDPRD(@cProduto,@oProduto,@cArmazem,aCabecIte) ,CriaVar("B1_COD",.F.))  F3 "SB1" FONT oFnt1 COLOR CLR_BLACK SIZE 100,10 Pixel
                                                                                                                                      
oGetGrade:=MsNewGetDados():New(10,10,10,10,GD_UPDATE+GD_DELETE,,,,aAlter,,999,,,,oLayer:getWinPanel('Col01','L2_Win01','Lin01'),@aCabecIte,@aDadosIte)
oGetGrade:oBrowse:Align	:= CONTROL_ALIGN_ALLCLIENT
//oGetGrade:bDelOk 		   	:= {|| Ft010Del(@nTotProd,@oTotProd,@nTotQtd,@oTotQtd) }
oGetGrade:bDelOk 			:= {|| DelLinha(oGetGrade:nAt,@nTotProd,@oTotProd,@nTotQtd,@oTotQtd) }

@ 05,010 SAY "Total Produtos: " Of oLayer:getWinPanel('Col01','L3_Win01','Lin01') FONT oFnt COLOR CLR_BLUE Pixel SIZE 60,10
@ 02,056 MSGET oTotProd VAR nTotProd Of oLayer:getWinPanel('Col01','L3_Win01','Lin01') PICTURE PesqPict("SC6","C6_QTDVEN") WHEN .F. FONT oFnt COLOR CLR_BLACK SIZE 60,10 Pixel

@ 05,130 SAY "Qtde Total: " Of oLayer:getWinPanel('Col01','L3_Win01','Lin01') FONT oFnt COLOR CLR_BLUE Pixel SIZE 60,10
@ 02,170 MSGET oTotQtd VAR nTotQtd Of oLayer:getWinPanel('Col01','L3_Win01','Lin01') PICTURE PesqPict("SC6","C6_QTDVEN") WHEN .F. FONT oFnt COLOR CLR_BLACK SIZE 60,10 Pixel


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IIF( VLDSAIDA(@lConfirma,cCliente,cLojaCli,oGetGrade) , oDlg:End() , .F. ) },{|| oDlg:End() },,)

If lConfirma
	
	MsgRun("Gerando pedido...", "Aguarde...",{|| CursorWait(), InputSC5(cCliente,cLojaCli,oGetGrade), CursorArrow()})

EndIf

RestArea(aArea)

Return Nil


Static function VLDPRD(cProduto)
Local lRet := .T.       
Local nValor 	:= 0
Local nQtde	:= 0
Local nPrcUnit	:= 0 
Local lDigVlr	:= GetMv("VA_DIGIVLR",,.F.)

If Empty(cProduto)   

    lRet := .F.    
    cProduto  := CriaVar("B1_COD",.F.)  

Endif

If lRet

	Dbselectarea("SB1")
	Dbsetorder(1)
	If !Dbseek(xFilial("SB1")+cProduto)    
	    lRet := .F.                                
	    cProduto  := CriaVar("B1_COD",.F.) 
	Endif          

Endif

If lRet

	SB0->(dbSetOrder(1))
	SB0->(dbSeek(xFilial("SB0") + AvKey(cProduto,"B0_COD") ))
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + AvKey(cProduto,"B1_COD") ))
	
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + AvKey(cProduto,"B2_COD") + cArmazem ))
	nSaldo := SaldoSB2()
	
	If nSaldo < 1
		Aviso("Transferência","Saldo insuficiente.",{"OK"},2)
		lRet := .F.
	endif
    
    If lRet 		
		if !Empty(cArmazem)
		
			//if lDigVlr
			//	nValor := InfQtde()
			//else
			nValor	:= 1
				//nValor	:= VLDSALDO(@nValor)
			//endif
			
			if nValor > 0
			
				nPrcUnit := if(Left(cOperacao,1)=="1",SB2->B2_CM1,SB0->B0_PRV1)
			
				If Empty(oGetGrade:aCols[1,1])
				
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosProd]		:= SB1->B1_COD
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosDesc]		:= SB1->B1_DESC
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosUM]		:= SB1->B1_UM
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCodB]		:= SB1->B1_CODBAR
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosQtde]		:= nValor
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosNcm]		:= SB1->B1_POSIPI
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosLoc]		:= cArmazem
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCusto]	:= Round(nPrcUnit,2)
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosVazio] 	:= ''
					oGetGrade:aCols[Len(oGetGrade:aCols),Len(oGetGrade:aHeader)+1]:= .F.
					
				Else
					Aadd(oGetGrade:aCols,Array(Len(oGetGrade:aHeader)+1))
					
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosProd]		:= SB1->B1_COD
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosDesc]		:= SB1->B1_DESC
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosUM]		:= SB1->B1_UM
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCodB]		:= SB1->B1_CODBAR
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosQtde]		:= nValor
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosNcm]		:= SB1->B1_POSIPI
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosLoc]		:= cArmazem
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCusto]	:= Round(nPrcUnit,2)
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosVazio] 	:= ''
					oGetGrade:aCols[Len(oGetGrade:aCols),Len(oGetGrade:aHeader)+1]:= .F.
				endif
				
			endif
		endif
		
		Eval(bRefresh)  
		
	Endif
	
Endif
return lRet
          

/*--------------------------------------------
@Autor: Mauricio Dizimbat
@Data: 26/03/2020
@Descrição: Valida armazém
--------------------------------------------*/
Static function VLDARMZ(cArmazem)
Local lRet := .T.       
Local nValor 	:= 0
Local nQtde	:= 0
Local nPrcUnit	:= 0 
Local lDigVlr	:= GetMv("VA_DIGIVLR",,.F.)

If Empty(cArmazem)   

    lRet := .F.    
    cArmazem  := CriaVar("NNR_CODIGO",.F.)  

Endif

If lRet

	Dbselectarea("NNR")
	Dbsetorder(1)
	If !Dbseek(xFilial("NNR")+cArmazem)    
	    lRet := .F.                                
	    cArmazem  := CriaVar("NNR_CODIGO",.F.) 
	Endif          

Endif

/*If lRet

	SB0->(dbSetOrder(1))
	SB0->(dbSeek(xFilial("SB0") + AvKey(cProduto,"B0_COD") ))
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + AvKey(cProduto,"B1_COD") ))
	
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2") + AvKey(cProduto,"B2_COD") + cArmazem ))
	nSaldo := SaldoSB2()
	
	If nSaldo < 1
		Aviso("Transferência","Saldo insuficiente.",{"OK"},2)
		lRet := .F.
	endif
    
    If lRet 		
		if !Empty(cProduto)
		
			//if lDigVlr
			//	nValor := InfQtde()
			//else
			nValor	:= 1
				//nValor	:= VLDSALDO(@nValor)
			//endif
			
			if nValor > 0
			
				nPrcUnit := if(Left(cOperacao,1)=="1",SB2->B2_CM1,SB0->B0_PRV1)
			
				If Empty(oGetGrade:aCols[1,1])
				
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosProd]		:= SB1->B1_COD
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosDesc]		:= SB1->B1_DESC
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosUM]		:= SB1->B1_UM
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCodB]		:= SB1->B1_CODBAR
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosQtde]		:= nValor
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosNcm]		:= SB1->B1_POSIPI
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosLoc]		:= cArmazem
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCusto]	:= Round(nPrcUnit,2)
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosVazio] 	:= ''
					oGetGrade:aCols[Len(oGetGrade:aCols),Len(oGetGrade:aHeader)+1]:= .F.
					
				Else
					Aadd(oGetGrade:aCols,Array(Len(oGetGrade:aHeader)+1))
					
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosProd]		:= SB1->B1_COD
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosDesc]		:= SB1->B1_DESC
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosUM]		:= SB1->B1_UM
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCodB]		:= SB1->B1_CODBAR
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosQtde]		:= nValor
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosNcm]		:= SB1->B1_POSIPI
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosLoc]		:= cArmazem
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosCusto]	:= Round(nPrcUnit,2)
					oGetGrade:aCols[Len(oGetGrade:aCols),nPosVazio] 	:= ''
					oGetGrade:aCols[Len(oGetGrade:aCols),Len(oGetGrade:aHeader)+1]:= .F.
				endif
				
			endif
		endif
		
		Eval(bRefresh)  
		
	Endif
	
Endif*/

Return(lRet)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 09/05/2019
@Hora: 14:42:37
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Valida a saida da rotina.
---------------------------------------------
Change:
--------------------------------------------*/
Static function VLDSAIDA(lOk,cCliente,cLojaCli,oGetGrade)

	Local nX
	
	lOk := .T.

	if Empty(cCliente) .Or. Empty(cLojaCli)
		MsgStop("O código do cliente ou a loja do cliente deve ser informada.","Atenção")
		lOk := .F.
	endif

	IF lOk
		
		For nX := 1 To Len(oGetGrade:aCols)
			
			If !oGetGrade:aCols[nX,Len(oGetGrade:aHeader)+1]
			
				if Empty(oGetGrade:aCols[nX,nPosProd])
					MsgStop("É necessário preencher os produtos para prosseguir com a operação.","Atenção")
					lOk := .F.
					Exit
				endif
				
				if oGetGrade:aCols[nX,nPosCusto]==0
					MsgStop("Existem produtos sem custo unitário preenchido, por favor preencher todos os produtos zerados.","Atenção")
					lOk := .F.
					Exit
				endif
							
			endif
			
		Next
	
		IF lOk
			IF !MsgYesNo("Confirma a Geração do Pedido de Venda ?","Atenção","YESNO")
				lOk := .F.
			EndIF
		endif
	
	EndIF

Return(lOk)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 07/05/2019
@Hora: 11:05:27
@Versão: 1.0
@Uso: 
@Descrição: Geração do pedido de venda.
---------------------------------------------
Change:
--------------------------------------------*/
Static Function InputSC5(cCliente,cLojaCli,oGetGrade)

	Local aArea 		:= GetArea()
	Local aCab			:= {}
	Local aItens		:= {}
	Local aItem		:= {}
	Local nOpcAuto		:= 3 // Incluir
	Local nStack   	:= GetSX8Len() 	//Controle da numeracao sequencial
	Local cNumPV		:= ""				//GetSXENum("SC5","C5_NUM",,1)
	Local cTime		:= STRTRAN(TIME(),':')

	Local nTamItem		:= TAMSX3("C6_ITEM")[1]
	Local cCondPg		:= GetMv("MV_CONDPAD")	
	Local cTES			:= ""												//if(Left(cOperacao,1)=="1",cTESTRA,cTESCON)
	Local cNatur		:= "OUTROS"

	Local lCredito		:= .T.
	Local lEstoque		:= .T.
	Local lAvCred		:= .F.
	Local lAvEst		:= .T.//.F.
	Local lLiber		:= .T.
	Local lTransf		:= .F.
	Local lDentroEST
	Local lForaEST	
	
	Local nValor		:= 0
	Local nX			:= 0
	
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	DbSelectArea("SC5")
	DbSetOrder(1)
	
	cMay := "SC5"+ Alltrim(xFilial("SC5"))
	While SC5->(DbSeek(xFilial("SC5")+cNumPV)) .OR. !MayIUseCode(cMay+cNumPV)
		cNumPV := GetSXENum("SC5","C5_NUM",,1)
		ConFirmSX8()
	EndDo
	
	Aadd( aCab, { "C5_FILIAL"	, xFilial("SC5")	, Nil, POSICIONE("SX3",2,"C5_FILIAL","X3_ORDEM") } )
	Aadd( aCab, { "C5_NUM"		, cNumPV			, Nil, POSICIONE("SX3",2,"C5_NUM","X3_ORDEM") } )
	Aadd( aCab, { "C5_TIPO"		, "N"				, Nil, POSICIONE("SX3",2,"C5_TIPO","X3_ORDEM") } )
	Aadd( aCab, { "C5_CLIENTE"	, cCliente			, Nil, POSICIONE("SX3",2,"C5_CLIENTE","X3_ORDEM") } )
	Aadd( aCab, { "C5_LOJACLI"	, cLojaCli			, Nil, POSICIONE("SX3",2,"C5_LOJACLI","X3_ORDEM") } )
	Aadd( aCab, { "C5_CLIENT"	, cCliente			, Nil, POSICIONE("SX3",2,"C5_CLIENT","X3_ORDEM") } )
	Aadd( aCab, { "C5_LOJAENT"	, cLojaCli			, Nil, POSICIONE("SX3",2,"C5_LOJAENT","X3_ORDEM") } )
	Aadd( aCab, { "C5_CONDPAG"	, cCondPg			, Nil, POSICIONE("SX3",2,"C5_CONDPAG","X3_ORDEM") } )
	Aadd( aCab, { "C5_EMISSAO"	, dDatabase		, Nil, POSICIONE("SX3",2,"C5_EMISSAO","X3_ORDEM") } )
	Aadd( aCab, { "C5_MOEDA"		, 1					, Nil, POSICIONE("SX3",2,"C5_MOEDA","X3_ORDEM") } )
	Aadd( aCab, { "C5_TIPLIB"	, "1"				, Nil, POSICIONE("SX3",2,"C5_TIPLIB","X3_ORDEM") } )
	Aadd( aCab, { "C5_TXMOEDA"	, 1					, Nil, POSICIONE("SX3",2,"C5_TXMOEDA","X3_ORDEM") } )
	Aadd( aCab, { "C5_TPCARGA"	, "2"				, Nil, POSICIONE("SX3",2,"C5_TPCARGA","X3_ORDEM") } )
	Aadd( aCab, { "C5_GERAWMS"	, "1"				, Nil, POSICIONE("SX3",2,"C5_GERAWMS","X3_ORDEM") } )
	Aadd( aCab, { "C5_LIBEROK"	, "S"				, Nil, POSICIONE("SX3",2,"C5_LIBEROK","X3_ORDEM") } )
	Aadd( aCab, { "C5_NATUREZ"	, cNatur			, Nil, POSICIONE("SX3",2,"C5_NATUREZ","X3_ORDEM") } )
	
	if Left(cOperacao,1) == "1"
		Aadd( aCab, { "C5_01TPOP"	, "2"				, Nil, POSICIONE("SX3",2,"C5_01TPOP","X3_ORDEM") } )
		Aadd( aCab, { "C5_01OST"		, cTime				, Nil, POSICIONE("SX3",2,"C5_01OST","X3_ORDEM") } )
	else
		Aadd( aCab, { "C5_01TPOP"	, "3"				, Nil, POSICIONE("SX3",2,"C5_01TPOP","X3_ORDEM") } )
	endif
	Aadd( aCab, { "C5_ZZTRANS"	, "S"				, Nil, POSICIONE("SX3",2,"C5_ZZTRANS","X3_ORDEM") } )

	aCab := ASort(aCab,,,{|x,y| x[4] < y[4]})

	For nX := 1 To Len(oGetGrade:aCols)
	
		If !oGetGrade:aCols[nX,Len(oGetGrade:aHeader)+1]
	
			aItem := {}
		
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+oGetGrade:aCols[nX,nPosProd])
			
			nValor := oGetGrade:aCols[nX,nPosQtde] * oGetGrade:aCols[nX,nPosCusto]
			
			if Left(cOperacao,1)=="2" //Demonstração
				
				/*cEstado := Posicione("SM0",1,cEmpAnt+cFilAnt,"SM0_ESTENT")
				Do Case
					Case cEstado = "SP"
						cTES := SuperGetMV("ES_TESSP",.F.,"912")
					Case cEstado = "PR"
						cTES := SuperGetMV("ES_TESPR",.F.,"913")
					Case cEstado = "PE"
						cTES := SuperGetMV("ES_TESPE",.F.,"914")
					Case cEstado = "RJ"
						cTES := SuperGetMV("ES_TESRJ",.F.,"915")
				OtherWise
					cTESCON	:= GetMv("VA_TESCOSA",,"968")
					cTES 	:= cTESCON	
				Endcase*/
				
				Do Case
					Case cFilAnt $ "00|01|03|07" //SP
						cTES := SuperGetMV("ES_TESSP",.F.,"912")
					Case cFilAnt $ "05" //PR
						cTES := SuperGetMV("ES_TESPR",.F.,"913")
					Case cFilAnt $ "06" //PE
						cTES := SuperGetMV("ES_TESPE",.F.,"914")
					Case cFilAnt $ "02|04" //RJ
						cTES := SuperGetMV("ES_TESRJ",.F.,"915")
				OtherWise
					cTESCON	:= GetMv("VA_TESCOSA",,"968")
					cTES 	:= cTESCON	
				Endcase
				
			else //Transferencia
				cTES := FRetTES(cCliente,cLojaCli,SB1->B1_COD)
			endif
			
			AADD( aItem, { "C6_FILIAL"		, xFilial("SC6")						, Nil, POSICIONE("SX3",2,"C6_FILIAL","X3_ORDEM") } )
			AADD( aItem, { "C6_ITEM"			, StrZero(nX,nTamItem)				, Nil, POSICIONE("SX3",2,"C6_ITEM","X3_ORDEM")  } )
			AADD( aItem, { "C6_PRODUTO"		, SB1->B1_COD							, Nil, POSICIONE("SX3",2,"C6_PRODUTO","X3_ORDEM")  } )
			AADD( aItem, { "C6_UM"			, SB1->B1_UM							, Nil, POSICIONE("SX3",2,"C6_UM","X3_ORDEM")  } )
			AADD( aItem, { "C6_QTDVEN"		, oGetGrade:aCols[nX,nPosQtde]		, Nil, POSICIONE("SX3",2,"C6_QTDVEN","X3_ORDEM")  } )
			AADD( aItem, { "C6_PRCVEN"		, oGetGrade:aCols[nX,nPosCusto]		, Nil, POSICIONE("SX3",2,"C6_PRCVEN","X3_ORDEM")  } )
			AADD( aItem, { "C6_VALOR"		, nValor								, Nil, POSICIONE("SX3",2,"C6_VALOR","X3_ORDEM")  } )
			AADD( aItem, { "C6_TES"			, cTES									, Nil, POSICIONE("SX3",2,"C6_TES","X3_ORDEM")  } )
			AADD( aItem, { "C6_LOCAL"		, oGetGrade:aCols[nX,nPosLoc]		, Nil, POSICIONE("SX3",2,"C6_LOCAL","X3_ORDEM")  } )
			AADD( aItem, { "C6_CLI"			, cCliente								, Nil, POSICIONE("SX3",2,"C6_CLI","X3_ORDEM")  } )
			AADD( aItem, { "C6_LOJA"			, cLojaCli								, Nil, POSICIONE("SX3",2,"C6_LOJA","X3_ORDEM")  } )
			AADD( aItem, { "C6_ENTREG"		, dDataBase							, Nil, POSICIONE("SX3",2,"C6_ENTREG","X3_ORDEM")  } )
			AADD( aItem, { "C6_NUM"			, cNumPV								, Nil, POSICIONE("SX3",2,"C6_NUM","X3_ORDEM")  } )
			AADD( aItem, { "C6_DESCRI"		, SB1->B1_DESC							, Nil, POSICIONE("SX3",2,"C6_DESCRI","X3_ORDEM")  } )
			AADD( aItem, { "C6_PRUNIT"		, oGetGrade:aCols[nX,nPosCusto]		, Nil, POSICIONE("SX3",2,"C6_PRUNIT","X3_ORDEM")  } )
			AADD( aItem, { "C6_GRADE"		, "N"									, Nil, POSICIONE("SX3",2,"C6_GRADE","X3_ORDEM")  } )
			AADD( aItem, { "C6_TPOP"			, "F"									, Nil, POSICIONE("SX3",2,"C6_TPOP","X3_ORDEM")  } )
			AADD( aItem, { "C6_SUGENTR"		, dDataBase							, Nil, POSICIONE("SX3",2,"C6_SUGENTR","X3_ORDEM")  } )
	
			aItem := ASort(aItem,,,{|x,y| x[4] < y[4]})
		
			AADD( aItens, aItem )
			
		endif

	Next nX

	//MATA410(xAutoCab,xAutoItens,nOpcAuto,lSimulacao,cRotina,cCodCli,cLoja,xRatCTBPC,xAdtPC,xParamAuto)
	MSExecAuto({|x,y,z| MATA410(x,y,z)}, aCab, aItens, nOpcAuto )
	
	If lMsErroAuto // ERRO
		MostraErro()
		
		While ( GetSX8Len() > nStack )
			RollBackSX8()
		EndDo
		RestArea(aArea)
		Return .F.
	Else
		EvalTrigger()		
		While ( GetSX8Len() > nStack )
			ConFirmSX8()
		EndDo

		DbSelectArea("SC5")
		DbSetOrder(1) // C5_FILIAL+C5_NUM
		if DbSeek(xFilial("SC5")+cNumPV)
			RecLock("SC5",.F.)
			SC5->C5_LIBEROK := "S"
			Msunlock()
			cNumPed := cNumPV
		endif
		
		MsgInfo("Pedido de venda gerado com sucesso: "+cNumPV,"Atenção")
	EndIf

	// Libera itens do pedido de venda
	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek(xFilial("SC6")+cNumPV)
	While SC6->(!EOF()) .AND. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+cNumPV
	
		DbSelectArea("SC6")
		MaLibDoFat(SC6->(RECNO()),SC6->C6_QTDVEN,@lCredito,@lEstoque,lAvCred,lAvEst,lLiber,lTransf)
	
		SC6->(DbSkip())
	EndDo
		
	// Restaura area original
	RestArea(aArea)

Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 07/05/2019
@Hora: 14:17:00
@Versão: 1.0
@Uso: VALETINO
@Descrição: Retorna o nome reduzido do cliente
--------------------------------------------*/
Static Function RetNomCli(oNomeCli,cNomeCli,cCliente,cLojaCli,oProduto,cPosiciona)

	cNomeCli:= CriaVar("A1_NREDUZ",.F.)

	SA1->(dbSetOrder())
	if SA1->(dbSeek(xFilial("SA1") + cCliente + cLojaCli ))
		cNomeCli:= SA1->A1_NREDUZ
	endif
	oNomeCli:Refresh()
	
	if cPosiciona=="S"
		oProduto:SetFocus()
	endif

Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 07/05/2019
@Hora: 15:38:10
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Monta aHeader e aCols
---------------------------------------------
Change:
--------------------------------------------*/
Static Function MntaHeader(aHeader,aCols)

	Local nY := 0

	Aadd( aHeader , { RetTitle('C6_PRODUTO') 	, 'PRODUTO' 	, PesqPict('SC6','C6_PRODUTO')	, TamSx3('C6_PRODUTO')[1], X3Decimal('C6_PRODUTO')	,'' ,'','C',''	,'','',''})
	Aadd( aHeader , { RetTitle('C6_DESCRI') 	, 'DESCRI' 	, PesqPict('SC6','C6_DESCRI')	, TamSx3('C6_DESCRI')[1] , X3Decimal('C6_DESCRI')		,''	,'','C',''	,'','',''})
	Aadd( aHeader , { RetTitle('C6_UM') 		, 'UM' 			, PesqPict('SC6','C6_UM')		, TamSx3('C6_UM')[1]		, X3Decimal('C6_UM')			,'' ,'','C',''	,'','',''})
	Aadd( aHeader , { RetTitle('B1_CODBAR') 	, 'CODBAR' 	, PesqPict('SB1','B1_CODBAR')	, TamSx3('B1_CODBAR')[1]	, X3Decimal('B1_CODBAR')		,'' ,'','C',''	,'','',''})
	Aadd( aHeader , { RetTitle('C6_QTDVEN') 	, 'QTDVEN' 	, PesqPict('SC6','C6_QTDVEN')	, TamSx3('C6_QTDVEN')[1]	, X3Decimal('C6_QTDVEN')		,'u_VLFAT10A()' ,'','N',''	,'','',''})
	Aadd( aHeader , { RetTitle('B1_POSIPI') 	, 'POSIPI' 	, PesqPict('SB1','B1_POSIPI')	, TamSx3('B1_POSIPI')[1]	, X3Decimal('B1_POSIPI')		,'' ,'','C',''	,'','',''})
	Aadd( aHeader , { RetTitle('C6_LOCAL') 		, 'LOCAL' 		, PesqPict('SC6','C6_LOCAL')		, TamSx3('C6_LOCAL')[1]	, X3Decimal('C6_LOCAL')		,'.T.' ,'','N','NNR','','',''})
	Aadd( aHeader , { RetTitle('C6_PRCVEN') 	, 'CUSTO' 		, PesqPict('SC6','C6_PRCVEN')	, TamSx3('C6_PRCVEN')[1]	, X3Decimal('C6_PRCVEN')	,'' ,'','N',''	,'','',''})
	Aadd( aHeader , { '' 							, 'FLAG'   	, ''								, 1							, 0								,'' ,'','C',''	,'','',''})
	
	aAlter := {'QTDVEN', 'CUSTO'}
	
	//----------------------------------------------------------------------------------------
	// Cria linha em branco
	//----------------------------------------------------------------------------------------
	Aadd(aCols,Array(Len(aHeader)+1))
	
	For nY := 1 To Len(aHeader)
		IF aHeader[nY,8] == 'N'      
			aCols[Len(aCols),nY] := 0
		ElseIF aHeader[nY,8] == 'C'      
			aCols[Len(aCols),nY] := ''	
		ElseIF aHeader[nY,8] == 'D'      
			aCols[Len(aCols),nY] := Ctod('')
		EndIF
	Next
	aCols[Len(aCols),Len(aHeader)+1] := .F.
	
Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 08/05/2019
@Hora: 11:24:41
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Valida os saldos do estoque.
---------------------------------------------
Change:
--------------------------------------------*/
User function VLFAT10A()

	Local lRet 	:= .T.
	Local nLinha	:= oGetGrade:oBrowse:nAt
	Local cProduto	:= oGetGrade:aCols[nLinha,nPosProd]
	Local cLocal	:= oGetGrade:aCols[nLinha,nPosLoc]
	Local nQtde	:= M->QTDVEN
	Local nSaldo	:= 0
	
	SB2->(dbSetOrder(1))
	if SB2->(dbSeek(xFilial("SB2") + AvKey(cProduto,"B2_COD") + cLocal ))
		nSaldo := SaldoSB2()
	endif
	
	If nQtde > nSaldo
		Aviso("Transferência","Saldo insuficiente.",{"OK"},2)
		lRet := .F.
	endif
	
	if lRet
		Eval(bRefresh)
	endif
		
Return(lRet)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 08/05/2019
@Hora: 13:50:02
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Atualiza os totais do rodape.
---------------------------------------------
Change:
--------------------------------------------*/
Static Function AtuRodape(cProduto,oProduto,nTotProd,oTotProd,nTotQtd,oTotQtd,oGetGrade)
	
	Local nTotProd 	:= 0
	Local nTotQtd  	:= 0
	
	aEval( oGetGrade:aCols , { |x| nTotProd 	+= 1 			} )
	aEval( oGetGrade:aCols , { |x| nTotQtd 		+= x[nPosQtde]	} )
	
	oTotProd:Refresh()
	oTotQtd:Refresh()
	
	oGetGrade:oBrowse:nAt	:= 1
	oGetGrade:oBrowse:Refresh()
	oGetGrade:Refresh()

	//cArmazem:=CriaVar("NNR_CODIGO",.F.)    
	//oArmazem:Refresh()   
		
	cProduto:=CriaVar("B1_COD",.F.)       
	oProduto:SetFocus()
	oProduto:Refresh()   

	
Return

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 08/05/2019
@Hora: 14:18:37
@Versão: 1.0
@Uso: 
@Descrição: Tela para digitação da quantidade 
---------------------------------------------
Change:
--------------------------------------------*/
Static Function InfQtde(nValor)
	
	Local nOpcao 	:= 0
	Local oPanel
	Local oFnt
	Local oValor
	Local oMainWnd
	Local oDlg1
	
	nValor 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a fonte da tela.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE FONT oFnt NAME "TAHOMA" SIZE 0,-16 BOLD

	DEFINE MSDIALOG oDlg1 FROM 0,0 TO 150,400 TITLE "Informe a(s) quantidade(s)" Of oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

	oDlg1:lEscClose := .F.

	oPanel:= TPanel():New(0, 0, "", oDlg1, NIL, .T., .F., NIL, NIL, 0,0, .T., .F. )
	oPanel:Align:=CONTROL_ALIGN_ALLCLIENT
	oPanel:NCLRPANE:=14803406

	@ 08,010 SAY "Quantidade(s): " Of oPanel FONT oFnt COLOR CLR_BLUE Pixel SIZE 80,10
	@ 07,088 MSGET oValor VAR nValor Of oPanel PICTURE PesqPict("SC6","C6_QTDVEN") VALID ( (nValor > 0) ) FONT oFnt COLOR CLR_BLACK SIZE 60,10 Pixel
		
	ACTIVATE MSDIALOG oDlg1 CENTERED ON INIT EnchoiceBar(oDlg1,{|| nOpcao:=1, oDlg1:End() },{|| nOpcao:=0, oDlg1:End() },,)
	
	//If nOpcao == 1
	 //	VLDSALDO(@nValor)
	//EndIf

Return(nValor)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 08/05/2019
@Hora: 14:45:04
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Valida os saldos do estoque.
---------------------------------------------
Change:
--------------------------------------------*/
Static function VLDSALDO(nValor)

	Local nSaldo 	:= 0
	
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + AvKey(cProduto,"B1_COD") ))

	SB2->(dbSetOrder(1))
	if SB2->(dbSeek(xFilial("SB2") + AvKey(cProduto,"B2_COD") + SB1->B1_LOCPAD ))
		nSaldo := SaldoSB2()
	endif
	
	If nValor > nSaldo
		MsgStop("Saldo insuficiente para transferência.","Atenção")
		nValor := 0
	endif
		
Return(nValor)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 09/05/2019
@Hora: 15:40:41
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Função para deletar a linha.
---------------------------------------------
Change:
--------------------------------------------*/
Static Function DelLinha(nDelLin,nTotProd,oTotProd,nTotQtd,oTotQtd)

Local lDel 	:= .T.
Local lDelOld 	:= oGetGrade:aCols[nDelLin,Len(oGetGrade:aHeader)+1]

IF lDel
	
	//----------------------------------------------------------------------------------------
	//Forca Deletado para "enganar" o objeto.
	//----------------------------------------------------------------------------------------
	oGetGrade:aCols[nDelLin,Len(oGetGrade:aHeader)+1] := !oGetGrade:aCols[nDelLin,Len(oGetGrade:aHeader)+1]
	
	//----------------------------------------------------------------------------------------
	//Recalcula totais do rodapé.
	//----------------------------------------------------------------------------------------
	Ft010Del(@nTotProd,@oTotProd,@nTotQtd,@oTotQtd)

	//----------------------------------------------------------------------------------------
	//Retorna o Status original e devolve o controle ao objeto.
	//----------------------------------------------------------------------------------------
	oGetGrade:aCols[nDelLin,Len(oGetGrade:aHeader)+1] := lDelOld

EndIF

Return(lDel)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 08/05/2019
@Hora: 15:47:45
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Atualiza os totais do rodape
ao deletar uma linha.
---------------------------------------------
Change:
--------------------------------------------*/
Static Function Ft010Del(nTotProd,oTotProd,nTotQtd,oTotQtd)

	Local nTotProd 	:= 0
	Local nTotQtd  	:= 0
	Local nX			:= 0
	
	For nX := 1 To Len(oGetGrade:aCols)
	
		IF !oGetGrade:aCols[nX,Len(oGetGrade:aHeader)+1]
			nTotProd 	+= 1
			nTotQtd	 	+= oGetGrade:aCols[nX,nPosQtde]
		else
			//nTotProd 	-= 1
			//nTotQtd	 	-= oGetGrade:aCols[nX,nPosQtde]		
		endif
	
	Next nX
	oTotProd:Refresh()
	oTotQtd:Refresh()
	
Return(.T.)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 12/07/2019
@Hora: 10:58:02
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Browser do pedido de venda
--------------------------------------------*/
Static Function VABRWSC5(cNumPed)

Local aArea			:= GetArea()
Local aCores       	:= {}
Local aIndexSC5	   	:= {}
Local cFilQuery	   	:= ""  

Default cNumPed		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao das variaveis                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCores,{ "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' })			//Pedido em Aberto
Aadd(aCores,{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'})		   	//Pedido Encerrado
Aadd(aCores,{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'})		//Pedido Liberado
Aadd(aCores,{ "C5_BLQ == '1'",'BR_AZUL'})															//Pedido Bloquedo por regra
Aadd(aCores,{ "C5_BLQ == '2'",'BR_LARANJA'})														//Pedido Bloquedo por verba

Private cCadastro		:= "Atualização de Pedidos de Venda"
Private aRotina		:= MenuDef()
Private ARATCTBPC	:= {}                                                                                    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra somente o pedido gerado pela transferencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
cFilQuery := " C5_FILIAL			= '"+xFilial("SC5")+"'"
cFilQuery += " AND C5_01TPOP		IN('2','3') "
cFilQuery += " AND C5_NOTA		= ' ' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea('SC5')
DbSetOrder(1)
mBrowse(6,1,22,75,"SC5",,,,,,aCores,,,,,,,,IIF(!Empty(cFilQuery),cFilQuery,Nil))

If ( Len(aIndexSC5)>0 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza o uso da FilBrowse e retorna os indices padroes.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndFilBrw("SC5",aIndexSC5)
EndIf			

RestArea(aArea)

Return(.T.)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 12/07/2019
@Hora: 11:03:17
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Rotina de Menu 
--------------------------------------------*/
Static Function MenuDef()
  
Local aRotina := {		{ OemToAnsi("Pesquisar")			,"AxPesqui"	,0,1,0 ,.F.},;	
							{ OemToAnsi("Visual")				,"A410Visual"	,0,2,0 ,NIL},;
							{ OemToAnsi("Transferência")		,"U_VACRIATR"	,0,3,0 ,NIL},;
							{ OemToAnsi("Alterar")			,"A410Altera"	,0,4,0 ,NIL},; 
							{ OemToAnsi("Excluir")			,"A410Deleta"	,0,5,0	,NIL},;
							{ OemToAnsi("Prep.Doc.Saida")	,"Ma410PvNfs"	,0,2,0 ,NIL},;
							{ OemToAnsi("Legenda")			,"A410Legend"	,0,1,0 ,.F.} }
Return(aRotina)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 21/07/2019
@Hora: 12:20:40
@Versão: 1.0
@Uso: VALENTINO
@Descrição: Retorna a TES.
---------------------------------------------
Change:
--------------------------------------------*/
Static Function FRetTES(cCliente,cLojaCli,cProduto)

	Local cTES 		:= ""
	Local cNCMPRO		:= ""
	Local cNCMPER		:= GetMv("VA_NCMPERF",,"33030010|33030020")	//NCN de perfumes para tratamentos das transferencias
	Local cTESTRA		:= GetMv("VA_TESTRNO",,"764")					//TES para Transferencia
	Local cTESDEP		:= GetMv("VA_TESTRDE",,"769")					//TES para Transferencia dentro do estado perfumes
	Local cTESFEP		:= GetMv("VA_TESTRFE",,"766")					//TES para Transferencia fora do estado perfumes
	Local cESTSM0		:= SM0->M0_ESTENT
	
	Local lDentroEST	:= .F.
	Local lForaEST		:= .F.
	Local aDadosFil    := FWSM0UTIL():GetSM0Data()
	
	SA1->(DbSetOrder(1))
	SA1->(Dbseek(xFilial("SA1") + cCliente + cLojaCli ))
		
	lDentroEST	:= cESTSM0 == SA1->A1_EST
	lForaEST	:= cESTSM0 <> SA1->A1_EST
	
	SB1->(DbSetOrder(1))
	SB1->(Dbseek(xFilial("SB1") + cProduto ))
	
	if Alltrim(SB1->B1_POSIPI) $ cNCMPER .And. lDentroEST
		cTES := cTESDEP
	
	elseif Alltrim(SB1->B1_POSIPI) $ cNCMPER .And. lForaEST
		cTES := cTESFEP
	
	// Transferencia entre lojas nao tem IPI
	elseIf aDadosFil[aScan(aDadosFil,{|x| Alltrim(x[1]) = "M0_CGC"}),2] <> "14720010000106"
		cTES := GetMv("ZZ_TESTRFI",,"771")
	Else
		cTES := cTESTRA
		
	endif
	
Return(cTES)
