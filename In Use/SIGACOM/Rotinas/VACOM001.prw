#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} User Function VACOM001
    Rotina responsável por criar a amarração dos produtos x fornecedores na importação de planilha Excel.
    Chamado pela rotina CSCOM002.
    @type  Function
    @author Muriel Zounar
    @since 28/08/2024
    @param PARAMIXB, ARRAY, Dados do produto.
    @param PARAMIXB[1]: Código do produto
    @param PARAMIXB[2]: Descrição do produto
    /*/
User Function VACOM001()
    Local aArea   := GetArea()
	Local aForLoj := {}
	Local aFornec := StrTokArr(GetMV('ZZ_FORNPRD'), ';')
	Local cDescr  := PARAMIXB[2]
	Local cForn   := ''
	Local cLoja   := ''
	Local cProd   := PARAMIXB[1]
	Local nI  	  := 0

	if !Empty(aFornec)
		if !Select('SA5')
			DbSelectArea('SA5')
		endif

		SA5->(DbSetOrder(2)) //?A5_FILIAL + A5_PRODUTO + A5_FORNECE + A5_LOJA

		for nI := 1 to Len(aFornec)
			cForn := SubStr(aFornec[nI], 1, 6)
			cLoja := SubStr(aFornec[nI], 7, 2)

			if !SA5->(DbSeek(xFilial('SA5') + cProd + cForn + cLoja))
				Aadd(aForLoj, {cForn, cLoja})
			endif
		next

		if !Empty(aForLoj)
			CriaPrdForn(cProd, cDescr, aForLoj)
		endif
	endif

	RestArea(aArea)
Return

Static Function CriaPrdForn(cProd, cDescr, aForn)
	Local cForn   	:= ''
	Local cLoja   	:= ''
	Local cNomeForn := ''
	Local nI	    := 0
	Local nOpc 	    := 3
	Local oModel    := FWLoadModel('MATA061')
	
	oModel:SetOperation(nOpc)
	oModel:Activate()

	//Cabeçalho
	oModel:SetValue('MdFieldSA5','A5_PRODUTO', cProd)
	oModel:SetValue('MdFieldSA5','A5_NOMPROD', cDescr)

	//Grid
	for nI := 1 to Len(aForn) 
		if nI > 1
			oModel:GetModel('MdGridSA5'):AddLine()
		endif

		cForn 	  := aForn[nI][1]
		cLoja 	  := aForn[nI][2]
		cNomeForn := Posicione('SA2', 1, xFilial('SA2') + cForn + cLoja, 'A2_NOME')
	
		oModel:SetValue('MdGridSA5','A5_FORNECE', cForn)
		oModel:SetValue('MdGridSA5','A5_LOJA' 	, cLoja)
		oModel:SetValue('MdGridSA5','A5_NOMEFOR', cNomeForn)
		oModel:SetValue('MdGridSA5','A5_CODPRF',cProd)
	next

	if oModel:VldData()
		oModel:CommitData()
	endif

	oModel:DeActivate()
	oModel:Destroy()
Return
