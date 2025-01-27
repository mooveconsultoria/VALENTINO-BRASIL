#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT100GRV ºAutor  ³ Controle           º Data ³  Unknown    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ P.E. que grava os dados da declaração de importação de uma º±±
±±º          ³ nota de entrada de importação                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico CONTROLE - Vários Clientes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION MT100GRV()

Local _aArea      := GetArea()

//Variaveis declaradas para empresa 2h
Local lExp01 	:= PARAMIXB[1]
Local nX		:= 1
Local cDocImp	:= ""
Local cSrImp	:= ""
Local cForImp	:= ""
Local cLojImp	:= ""
Local cDocImp	:= ""
Local cForLoj	:= GetMv("VA_XFORIMP",,"00030601")
//Variaveis declaradas para empresa 2h

Private oDlg
Private cNumDI    := Space(10)
Private cLocde    := Space(15)
Private cUFDe     := Space(02)
Private dDataDI   := Date()
Private dDataDes  := Date()
Private aComboBox := {"0=Declaração de Importação","1=Declaração Simplificada de Importação","2=RECOF - Declaração de Admissão","3=Outros"}
Private cTipDoc   := ""
Private oFont6    := NIL

If AllTrim(SM0->M0_CODIGO) $ "5L/BZ/T7/F6/5I/N6/Z4/UQ/E7"
	
	IF INCLUI
		
		dbSelectArea("SF1")
		dbSetOrder(1)
		dbSeek(xFilial("SF1")+cNFiscal+cSerie+cA100For+cLoja+cTipo)
		
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+cA100For+cLoja)
		
		If SA2->A2_EST == "EX"
			
			DEFINE FONT oFont6 NAME "ARIAL" BOLD
			DEFINE MSDIALOG oDlg FROM 284,192 TO 491,643 TITLE "Importação" OF oDlg PIXEL
			
			@ 004,010 TO 102,180 LABEL "" OF oDlg PIXEL
			
			@ 015,017 SAY "Numero de DI: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
			@ 013,075 MsGet oEdit Var cNumDI Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg
			
			@ 030,017 SAY "Localidade: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
			@ 028,075 MsGet oEdit Var cLocde PICTURE "@!" Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg
			
			@ 045,017 SAY "UF Dembaraço: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
			@ 043,075 MsGet oEdit Var cUFDe Picture "@!" Size 060,009 COLOR CLR_BLACK PIXEL OF oDlg
			
			@ 060,017 SAY "Data de DI: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
			@ 058,075 MsGet oEdit1 Var dDataDI Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg
			
			@ 075,017 SAY "Data Desemb.: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
			@ 073,075 MsGet oEdit2 Var dDataDes Size 045,009 COLOR CLR_BLACK PIXEL OF oDlg
			
			@ 090,017 SAY "Tipo de Documento: " OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
			@ 088,075 Combobox cTipDoc Items aComboBox Size 105,009 PIXEL OF oDlg
			
			@ 19,187 BUTTON "&Ok"      SIZE 036,012 ACTION (Clickok())  OF oDlg PIXEL
			@ 34,187 BUTTON "&Cancela" SIZE 036,012 ACTION (Cancel())   OF oDlg PIXEL
			
			Activate MsDialog oDlg Centered
			
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validação para documento de importação 2H.   ³
//|Fernando Lavor 03/03/2015					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cEmpAnt == "2H"
	For nX := 1 To Len(aCols)
		
		If !Empty(SF1->F1_XDOCIMP) .And. aCols[nX][Len(aHeader)+1] == .F.
			
			cDoc	:=	Alltrim(aCols[nX,aScan(aHeader,{|x|AllTrim(x[2])=="D1_DOC"})])
		    cSrImp	:=	SF1->F1_SERIE   //cSrImp	:=	GetMv("VA_XSRIMP",,"2") 
//			cForImp :=	SubStr(cForLoj,1,6)//Alltrim(aCols[Len(aCols),aScan(aHeader,{|x|AllTrim(x[2])=="D1_FORNECE"})])
			cForImp :=	SA2->A2_COD
//			cLojImp	:=	SubStr(cForLoj,7,2)//Alltrim(aCols[Len(aCols),aScan(aHeader,{|x|AllTrim(x[2])=="D1_LOJA"})])
			cLojImp	:=	SA2->A2_LOJA
			cDocImp	:=	SF1->F1_XDOCIMP
			cEst	:=	Posicione("CC2",2,xFilial("CC2")+Upper(FwNoAccent(Alltrim(SF1->F1_XLOCDES))),"CC2_CODMUN")
			
			DbSelectArea("CD5")
			DbSetOrder(4)
			If !DbSeek(xFilial("CD5")+cDoc+cSrImp+Space(TamSx3("CD5_SERIE")[1]-Len(cSrImp))+cForImp+cLojImp+aCols[nX,aScan(aHeader,{|x|AllTrim(x[2])=="D1_ITEM"})]);
			.AND. SA2->A2_EST == "EX"
				
				RecLock("CD5",.T.)
				
				//Escreve CD5 Fernando Lavor
				CD5->CD5_FILIAL :=	xFilial("CD5")
				CD5->CD5_DOC	:=	cDoc
				CD5->CD5_SERIE	:=	cSrImp
				CD5->CD5_ESPEC	:=	'SPED'//Alltrim(aCols[Len(aCols),aScan(aHeader,{|x|AllTrim(x[2])=="D1_ESPECIE"})])
				CD5->CD5_FORNEC	:=	cForImp
				CD5->CD5_LOJA	:=	cLojImp
				CD5->CD5_DOCIMP	:=	cDocImp
				CD5->CD5_NDI	:=	cDocImp
				CD5->CD5_DTDI	:=	SF1->F1_XDTDI
				CD5->CD5_LOCDES	:=	SF1->F1_XLOCDES
				CD5->CD5_UFDES	:=	CC2->CC2_EST
				CD5->CD5_DTDES	:=	SF1->F1_XDTDES
				CD5->CD5_CODEXP	:= 	cForImp
				CD5->CD5_NADIC	:=  '001'
				CD5->CD5_SQADIC	:=	SubStr(aCols[nX,aScan(aHeader,{|x|AllTrim(x[2])=="D1_ITEM"})],2,4)
				CD5->CD5_CODFAB	:=	cForImp
				CD5->CD5_ITEM	:=	aCols[nX,aScan(aHeader,{|x|AllTrim(x[2])=="D1_ITEM"})]
				CD5->CD5_LOJEXP	:=	cLojImp
				CD5->CD5_LOJFAB	:=	cLojImp
				CD5->CD5_TPIMP	:=	'0'
				CD5->CD5_LOCAL	:=	'0'  
				CD5->CD5_VTRANS :=  '4' // colocado campos conforme solicitação do cliente Wesley
				CD5->CD5_INTERM :=  '1' // colocado campos conforme solicitação do cliente Wesley
				MsUnLock()
			ElseIf 	lExp01
				cUpd := " UPDATE "+RetSqlName("CD5")+" CD5 "
				cUpd += " SET CD5.R_E_C_D_E_L_ = CD5.R_E_C_N_O_, CD5.D_E_L_E_T_ = '*' "
				cUpd += " WHERE
				cUpd += " CD5.R_E_C_N_O_ = '"+cValToChar(CD5->(RECNO()))+"'
				TcSqlExec(cUpd)
			EndIf
			
		Else
			Loop
		EndIf
	Next
EndIf
RestArea(_aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CANCEL   ºAutor  ³ Controle           º Data ³  Unknown    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cancela quaisquer operações, a partir do acionamento do    º±±
±±º          ³ botão CANCELA                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CONTROLE - Varios Clientes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Cancel()

ApMsgStop(OemToAnsi("Informações não serão gravadas!"),OemToAnsi("ATENÇÃO"))

oDlg:End()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CLICKOK  ºAutor  ³ Controle           º Data ³  Unknown    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa quaisquer operações, a partir do acionamento do   º±±
±±º          ³ botão OK                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico CONTROLE - Varios Clientes                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ClickOK()

Local _lOk := .F.

dbSelectArea("SF1")
dbSetOrder(1)
dbSeek(xFilial("SF1")+cNFiscal+cSerie+cA100For+cLoja+cTipo)

dbSelectArea("CD5")
dbSetOrder(1)

If ApMsgYesNo(OemToAnsi("Não Existe informação! Deseja gravar as informações ?"),OemToAnsi("ATENÇÃO"))
	
	_lOk := .T.
	
	RecLock("CD5",.T.)
	CD5->CD5_FILIAL := xFilial("SF1") // SF1->F1_FILIAL
	CD5->CD5_DOC	   := cNFiscal       // SF1->F1_DOC
	CD5->CD5_SERIE  := cSerie         // SF1->F1_SERIE
	CD5->CD5_ESPEC  := cEspecie       // SF1->F1_ESPECIE
	CD5->CD5_FORNEC := cA100For       // SF1->F1_FORNECE
	CD5->CD5_LOJA   := cLoja          // SF1->F1_LOJA
	CD5->CD5_TPIMP  := cTipDoc
	CD5->CD5_DOCIMP := cNumDI
	CD5->CD5_DTDI   := dDataDI
	CD5->CD5_LOCDES := cLocde
	CD5->CD5_UFDES  := cUFDe
	CD5->CD5_DTDES  := dDataDes
	CD5->CD5_NDI    := cNumDI
	CD5->CD5_CODEXP := cA100For
	CD5->CD5_CODFAB := cA100For
	CD5->CD5_NADIC  := "1"
	CD5->CD5_SQADIC := "1"
	MsUnLock()
	
EndIf

If _lOK
	ApMsgInfo(OemToAnsi("Dados gravados com sucesso!"),OemToAnsi("ATENÇÃO"))
Else
	ApMsgInfo(OemToAnsi("Dados não gravados!"),OemToAnsi("ATENÇÃO"))
EndIf

oDlg:End()

Return
