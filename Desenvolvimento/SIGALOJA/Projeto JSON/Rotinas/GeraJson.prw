#Include "Protheus.ch"

User Function GeraJson(_cTipo,_cChave,_cOper,_cModo)
Local _aArea    := GetArea()
Local _aFormas  := {}
Local _n
Local _aItens   := {}
Local _cDirUsr  := GetNewPar("ZZ_LOCJSON","\json\")

If _cTipo $ "1&2&4&5"

    DbSelectArea("SF2")
    DbSetOrder(1)
    DbGotop()

    If DbSeek(_cChave)

        If _cTipo = "1"

            DbSelectArea("SL1")
            DbSetOrder(2)
            DbGotop()

            If !DbSeek(SF2->(F2_FILIAL+F2_SERIE+F2_DOC))

                _cErro += "Orçamento não encontrado: "+_cChave+Chr(13)+Chr(10)
                Return .F.

            Endif        

        Endif
        
        DbSelectArea("SE1")
        DbSetOrder(1)
        DbGoTop()

        If DbSeek(xFilial("SE1")+SF2->(F2_SERIE+F2_DOC))
            
            Do While    SE1->E1_FILIAL = xFilial("SE1") .And.;
                        SE1->(E1_PREFIXO+E1_NUM) = SF2->(F2_SERIE+F2_DOC) .And. !Eof()

                If Len(_aFormas) > 0

                    _lTem := .F.

                    For _n := 1 to Len(_aFormas)

                        If _aFormas[_n][1] = Rtrim(SE1->E1_TIPO)

                            _aFormas[_n][2] += If(SE1->E1_VLRREAL=0,SE1->E1_VALOR,SE1->E1_VLRREAL)
                            _lTem := .T.
                                
                        Endif
                            
                    NEXT

                    If !_lTem

                        AADD(_aFormas,{Rtrim(SE1->E1_TIPO),If(SE1->E1_VLRREAL=0,SE1->E1_VALOR,SE1->E1_VLRREAL)})

                    Endif
                    
                else
                    
                    AADD(_aFormas,{Rtrim(SE1->E1_TIPO),If(SE1->E1_VLRREAL=0,SE1->E1_VALOR,SE1->E1_VLRREAL)})

                Endif

                DbSkip()

            Enddo

        else
                
            _cErro += "Parcelas da venda não encontradas: "+_cChave+Chr(13)+Chr(10)
            Return .F.

        Endif

        _aPay := {}
        _aVal :={}

        For _n := 1 to Len(_aFormas)

            AADD(_aPay,_aFormas[_n][1])
            AADD(_aVal,_aFormas[_n][2])

        Next


    //    If _cTipo = "1" //Vendas

            cArquivo := "SF2"+Rtrim(SF2->F2_DOC)+RTRIM(SF2->F2_SERIE)+If(_cOper="C","C","")+".json"

            oJson := JSonObject():New()

            oJson['InvoiceType']        := _cTipo
            oJson['Branch']             := SF2->F2_FILIAL + '-' + BuscaArmazem(1) //? Muriel (13/05/2024)
            oJson['BranchName']         := If(_cOper="N",SM0->M0_NOME,If(cEmpAnt="99",SA1->A1_COD,SA1->A1_XIDRETA))
            oJson['InvoiceDateOf']      := SF2->F2_EMISSAO
            oJson['InvoiceDateTo']      := SF2->F2_EMISSAO
            oJson['InvoiceNumber']      := SF2->(Rtrim(F2_DOC)+F2_SERIE)
            oJson['CustomerID']         := If(_cOper="N",If(cEmpAnt="99",SA1->A1_COD,SA1->A1_XIDRETA),SM0->M0_NOME)
            If _cTipo = "1"
                oJson['SalesType']      := If(Len(FWGetSX5("Z2", SL1->L1_ZZSLTYP  , "pt-br" ))=0,"",FWGetSX5("Z2", SL1->L1_ZZSLTYP  , "pt-br" )[1][4])
                oJson['%for']           := If(Len(FWGetSX5("Z3", SL1->L1_ZZPRFOR  , "pt-br" ))=0,"",FWGetSX5("Z3", SL1->L1_ZZPRFOR  , "pt-br" )[1][4])
            else
                oJson['SalesType']      := ""
                oJson['%for']           := ""
            Endif
            oJson['PaymentMethods']     := _aPay
            oJson['PaymentTotal']       := _aVal
            oJson['InvoiceTotal']    := SF2->F2_VALBRUT

            Reclock("SF2",.F.)
            SF2->F2_MSEXP   := Dtos(dDatabase)
            SF2->F2_HREXP   := Time()
            MsUnlock()    

            DbSelectArea("SD2")
            DbSetOrder(3)
            DbGoTop()
            DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE))

            Do While SD2->(D2_FILIAL+D2_DOC+D2_SERIE) = SF2->(F2_FILIAL+F2_DOC+F2_SERIE) .And. SD2->(!EOF())

                aAdd(_aItens,JsonObject():new())
                nPos := Len(_aItens)
                _aItens[nPos]['Item']          := SD2->D2_ITEM
                
                //? Muriel (20/05) - A pedido do Cristiano, quando for venda, a tag Seller deve receber o conteúdo de "A3_NREDUZ"
                if _cTipo == '1' //Vendas
                    _aItens[nPos]['Seller'] := Posicione('SA3', 1, xFilial('SA3') + RetVend(SL1->L1_NUM, SD2->D2_ITEM), 'A3_NREDUZ')
                else
                    _aItens[nPos]['Seller'] := Posicione('SA3', 1, xFilial('SA3') + RetVend(SL1->L1_NUM, SD2->D2_ITEM), 'A3_NOME')
                endif

                _aItens[nPos]['UAC']           := SD2->D2_COD
                _aItens[nPos]['Quantity']      := SD2->D2_QUANT
                _aItens[nPos]['UnityPrice']    := SD2->D2_PRCVEN
                _aItens[nPos]['DiscountPerc']  := SD2->D2_DESC
                _aItens[nPos]['DiscountAmout'] := SD2->D2_DESCON
                If _cTipo = "1"
                    _aItens[nPos]['DiscountType']  := If(Len(FWGetSX5("Z1", SL2->L2_ZZMTDSC   , "pt-br" ))=0,"",FWGetSX5("Z1", SL2->L2_ZZMTDSC  , "pt-br" )[1][4])
                else
                    _aItens[nPos]['DiscountType']  := ""
                Endif
                _aItens[nPos]['DTotalAmount']  := SD2->D2_TOTAL

                SD2->(DbSkip())
            Enddo

            oJson['items'] := _aItens
            Memowrite(_cDirUsr+cArquivo, oJson:ToJson())
            
            If !IsBlind()
                FwAlertInfo("Arquivo Gerado:"+_cDirUsr+cArquivo+" !")
            else
                Conout("Arquivo Json Gerado:"+_cDirUsr+cArquivo+" !")
            Endif

    //            CpyS2T(cArquivo, _cDirUsr)
    //            __CopyFile(cArquivo, _cDirUsr)
    //    Endif
    else
        
        _cErro += "NF não encontrada: "+_cChave+Chr(13)+Chr(10)
        Return .F.
    Endif
Else

    DbSelectArea("SF1")
    DbSetOrder(1)
    DbGotop()

    If DbSeek(_cChave)

        DbSelectArea("SE1")
        DbSetOrder(1)
        DbGoTop()

        If DbSeek(xFilial("SE1")+SF1->(F1_SERIE+F1_DOC))
            
            Do While    SE1->E1_FILIAL = xFilial("SE1") .And.;
                        SE1->(E1_PREFIXO+E1_NUM) = SF1->(F1_SERIE+F1_DOC) .And. !Eof()

                If Len(_aFormas) > 0

                    _lTem := .F.

                    For _n := 1 to Len(_aFormas)

                        If _aFormas[_n][1] = Rtrim(SE1->E1_TIPO)

                            _aFormas[_n][2] += SE1->E1_VALOR
                            _lTem := .T.
                                
                        Endif
                            
                    NEXT

                    If !_lTem

                        AADD(_aFormas,{Rtrim(SE1->E1_TIPO),SE1->E1_VALOR})

                    Endif
                    
                else
                    
                    AADD(_aFormas,{Rtrim(SE1->E1_TIPO),SE1->E1_VALOR})

                Endif

                DbSkip()

            Enddo

        else
                
            _cErro += "Parcelas da venda não encontradas: "+_cChave+Chr(13)+Chr(10)
            Return .F.

        Endif

        _aPay := {}
        _aVal :={}

        For _n := 1 to Len(_aFormas)

            AADD(_aPay,_aFormas[_n][1])
            AADD(_aVal,_aFormas[_n][2])

        Next


        cArquivo := "SF1"+Rtrim(SF1->F1_DOC)+RTRIM(SF1->F1_SERIE)+If(_cOper="C","C","")+".json"

        oJson := JSonObject():New()

        oJson['InvoiceType']        := _cTipo
        oJson['Branch']             := SF1->F1_FILIAL + '-' + BuscaArmazem(2) //? Muriel (13/05/2024)
        oJson['BranchName']         := If(_cOper="N",SM0->M0_NOME,SA2->A2_COD)
        oJson['InvoiceDateOf']      := SF1->F1_EMISSAO
        oJson['InvoiceDateTo']      := SF1->F1_EMISSAO
        oJson['InvoiceNumber']      := SF1->(Rtrim(F1_DOC)+F1_SERIE)
        oJson['CustomerID']         := If(_cOper="N",SA2->A2_COD,SM0->M0_NOME)

        if _cTipo == '3'
            aDevo := BuscaVend()
            oJson['SalesType'] := aDevo[1]
            oJson['%for']      := aDevo[2]
        else
            oJson['SalesType']          := ""
            oJson['%for']               := ""
        endif
        
        oJson['PaymentMethods']     := _aPay
        oJson['PaymentTotal']       := _aVal
        oJson['InvoiceTotal']       := SF1->F1_VALBRUT

        Reclock("SF1",.F.)
        SF1->F1_MSEXP   := Dtos(dDatabase)
        SF1->F1_HREXP   := Time()
        MsUnlock()    

        DbSelectArea("SD1")
        DbSetOrder(1)
        DbGoTop()
        DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE))

        Do While SD1->(D1_FILIAL+D1_DOC+D1_SERIE) = SF1->(F1_FILIAL+F1_DOC+F1_SERIE) .And. !Eof()

            aAdd(_aItens,JsonObject():new())
            nPos := Len(_aItens)
            _aItens[nPos]['Item']          := SD1->D1_ITEM
            
            if _cTipo == '3'
                _aItens[nPos]['Seller'] := Posicione('SA3', 1, xFilial('SA3') + RetVend(aDevo[3], SD1->D1_ITEMORI), 'A3_NREDUZ')
            else
                _aItens[nPos]['Seller'] := ""
            endif

            _aItens[nPos]['UAC']           := SD1->D1_COD
            _aItens[nPos]['Quantity']      := SD1->D1_QUANT
            _aItens[nPos]['UnityPrice']    := SD1->D1_VUNIT
            _aItens[nPos]['DiscountPerc']  := SD1->D1_DESC
            _aItens[nPos]['DiscountAmout'] := SD1->D1_VALDESC
            _aItens[nPos]['DiscountType']  := ""
            _aItens[nPos]['DTotalAmount']  := SD1->D1_TOTAL

            DbSkip()


        Enddo

        oJson['items'] := _aItens
        Memowrite(_cDirUsr+cArquivo, oJson:ToJson())
            
        If !IsBlind() .And. _cModo = "1"
            FwAlertInfo("Arquivo Gerado:"+_cDirUsr+cArquivo+" !")
        else
            Conout("Arquivo Json Gerado:"+_cDirUsr+cArquivo+" !")
        Endif


    else
        
        _cErro += "NF não encontrada: "+_cChave+Chr(13)+Chr(10)
        Return .F.

    Endif


Endif

RestArea(_aArea)
Return .T.

Static Function RetVend(_cNum,_cItem)
Local _cVend := SF2->F2_VEND1
Local _aArea := GetArea()

DbSelectArea("SL2")
DbSetOrder(1)
DbGoTop()

DbSeek(xFilial("SL2")+_cNum)

Do While    SL2->(L2_FILIAL+L2_NUM) = SL1->(L1_FILIAL+L1_NUM) .And. !Eof()

    If Val(L2_ITEM) = Val(_cItem)

        _cVend := SL2->L2_VEND
        Exit

    Endif 

    DbSkip()

Enddo 

RestArea(_aArea)
Return _cVend


User Function TstJson()

Default aEmp := {"99", "01"}

If Select("SX2") == 0
    RPCSetEnv(aEmp[1], aEmp[2])
EndIf

DbSelectArea("SF2")
DbGoto(8)

U_GeraJson("1",SF2->(F2_FILIAL+F2_DOC+F2_SERIE))

Return .T.

//? Retorna o código do armazém relacionado aos itens da nota - Muriel (13/05/2024)
Static Function BuscaArmazem(nOp)
    Local aArea    := GetArea()
    Local cArmazem := ''

    if nOp == 1
        DbSelectArea('SD2')
        SD2->(DbSetOrder(3))
        SD2->(DbGoTop())
        
        if SD2->(DbSeek(SF2->(F2_FILIAL + F2_DOC + F2_SERIE)))
            cArmazem := SD2->D2_LOCAL
        endif
    else
        DbSelectArea('SD1')
        SD1->(DbSetOrder(1))
        SD1->(DbGoTop())
        
        if SD1->(DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
            cArmazem := SD1->D1_LOCAL
        endif
    endif

    RestArea(aArea)
Return cArmazem

Static Function BuscaVend()
    Local aArea   := GetArea()
    Local aRet    := {}
    Local cNfOri  := ''
    Local cSerOri := ''
    Local cCliOri := ''
    Local cLojOri := ''

    DbSelectArea('SD1')
    SD1->(DbSetOrder(1))
    SD1->(DbGotop())

    if SD1->(DbSeek(xFilial('SD1') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
        cNfOri  := SD1->D1_NFORI
        cSerOri := SD1->D1_SERIORI
        cCliOri := SD1->D1_FORNECE
        cLojOri := SD1->D1_LOJA
        
        DbSelectArea('SF2')
        SF2->(DbSetOrder(1))
        SF2->(DbGotop())
        
        if SF2->(DbSeek(xFilial('SF2') + cNfOri + cSerOri + cCliOri + cLojOri))
            DbSelectArea('SL1')
            SL1->(DbSetOrder(2))
            SL1->(DbGotop())

            if SL1->(DbSeek(SF2->F2_FILIAL + cSerOri + cNfOri))
                Aadd(aRet, if(Len(FWGetSX5('Z2', SL1->L1_ZZSLTYP, 'pt-br')) == 0, '', FWGetSX5('Z2', SL1->L1_ZZSLTYP, 'pt-br')[1][4]))
                Aadd(aRet, if(Len(FWGetSX5('Z3', SL1->L1_ZZPRFOR, 'pt-br')) == 0, '', FWGetSX5('Z3', SL1->L1_ZZPRFOR, 'pt-br')[1][4]))
                Aadd(aRet, SL1->L1_NUM)
            endif      
        endif
    endif

    RestArea(aArea)
Return aRet
