<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="datatables" uri="http://github.com/dandelion/datatables" %>
<%@taglib prefix="dandelion" uri="http://github.com/dandelion" %>

<c:set var="linkController"><c:url value="/creditos/pendentes"/></c:set>

<dandelion:bundle includes="datatables.extended,floating.button,font-awesome5,jquery.validation,jquery.inputmask,bootstrap3.datetimepicker"/>

<html>

<head>
  <title>Créditos Pendentes</title>
  <meta name="header" content="Créditos Pendentes" />

  <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
  <script type="text/javascript">
      google.charts.load("current", {packages:["corechart"], 'language': 'pt_BR'});
      google.charts.setOnLoadCallback(graficoPorCategoria);
      function graficoPorCategoria() {
          var data = google.visualization.arrayToDataTable([
            ['Categoria', 'Valor']
            <c:forEach var="total" items="${totalPorCategoria}">
                ,['${total[1]}: <fmt:formatNumber value="${total[0]}" type="currency"/>', ${total[0]}]
            </c:forEach>
          ]);
          var options = { is3D: true, legend: { alignment: 'center' }, chartArea: { width: '100%', height: '100%' } };
          var chart = new google.visualization.PieChart(document.getElementById('graficoPorCategoria'));
          chart.draw(data, options);
        }
  </script>

</head>

<body>
  <script type="text/javascript">
      $(document).ready(function() {
          var formValidator = $("#form-pesquisar-receber").validate({
              rules : {
                  txt_data : { required : true }
              }
          });
          $("#btn_pesquisar").click(function() {
              var form = $("#form-pesquisar-receber"); 
              form.validate();
              if (form.valid()) {
                  form.submit();
              }
          });
          $("#txt_data").focus();
          $("#txt_data").inputmask("99/99/9999");
          $("#data").datetimepicker({locale: "pt-br", format: "DD/MM/YYYY"});
          $('[data-toggle="tooltip"]').tooltip();
      });
      function fnFooterCallback( row, data, start, end, display ) {
          var totalPage = 0;
          for (var i = start; i < end; i++) {
              totalPage += Number(data[display[i]].valor.replace('.', '').replace(',', '.'));
          }
          $("#totalAnalitico").html("Valor total exibido: R$ " + totalPage.toFixed(2));
      };
  </script>

  <%@include file="/layouts/modal-mensagens.jsp"%>
  <%@include file="/layouts/modal-confirmacoes.jsp"%>

  <form name="form-pesquisar-receber" id="form-pesquisar-receber" action="${linkController}">
    <%@include file="/layouts/modal-processando.jsp" %>
    <div class="row">
      <div class="form-group col-xs-12 col-md-4">
        <label for="txt_data" class="control-label">Até a Data</label>
        <div class="input-group date" id="data">
          <input type="text" name="txt_data" id="txt_data" class="form-control" value="${txt_data}"/>
          <span class="input-group-addon">
            <span class="fas fa-calendar-alt"></span>
          </span>
          <span class="input-group-btn">
            <button type="button" class="btn btn-primary" name="btn_pesquisar" id="btn_pesquisar"><span class="fas fa-search"></span> Pesquisar</button>
          </span>
        </div>
      </div>
    </div>
  </form>

  <div class="page-header" style="margin-top: -10px;">
    <h4>Relatório sintético: <small>Valor total: <fmt:formatNumber value="${total}" type="currency"/></small></h4>
  </div>
  
  <div class="row">
    <div class="col-xs-12 col-md-12" id="graficoPorCategoria" style="height: 150px;"></div>
  </div>

  <div class="page-header">
    <h4>Relatório analítico: <small id="totalAnalitico"></small></h4>
  </div>

  <a href="${linkController}/incluir" class="float-button"><span class="fas fa-plus fa-lg"></span></a>

  <datatables:table data="${listagemPendentes}" row="receber" id="GridDatatable" pageable="false">
    <c:set var="cssLinha">${receber.vencida ? 'danger' : receber.vencendo ? 'warning' : ''}</c:set>
    <datatables:column title="Descrição" property="descricao" cssCellClass="${cssLinha}"/>
    <datatables:column title="Categoria" property="categoria.descricao" cssCellClass="${cssLinha}"/>
    <datatables:column title="Vencimento" property="dataVencimentoJsp" format="{0,date,dd/MM/yyyy}" sortType="date-uk" sortInitDirection="asc" cssCellClass="text-center ${cssLinha}"/>
    <datatables:column title="Valor(R$)" property="valor" format="{0,number,#,##0.00}" cssCellClass="text-right ${cssLinha}"/>
    <datatables:column title="Opções" filterable="false" searchable="false" sortable="false" cssCellClass="text-center ${cssLinha}">
      <div class="btn-group">
        <button type="button" class="btn btn-default btn-circle dropdown-toggle" data-toggle="dropdown">
          <span class='fas fa-ellipsis-v'></span>
        </button>
        <ul class="dropdown-menu dropdown-menu-right">
          <li><a href="${linkController}/editar/${receber.id}"><span class='fas fa-pencil-alt'></span> Editar</a></li>
          <li>
            <a href="#" onclick="confirmarAlteracao('Confirmar o recebimento do crédito de ${receber.valor} do item ${receber.descricao}?', '${linkController}/liquidar/${receber.id}'); return false;">
              <span class='fas fa-dollar-sign'></span> Liquidar</a>
          </li>
          <li>
            <a href="#" onclick="confirmarExclusao('Deseja realmente excluir o lançamento de crédito de ${receber.valor} do item ${receber.descricao}?', '${linkController}/excluir/${receber.id}'); return false;">
              <span class='fas fa-trash-alt'></span> Excluir</a>
          </li>
        </ul>
      </div>
    </datatables:column>
    <datatables:callback function="fnFooterCallback" type="footer"/>
    <datatables:extraJs bundles="datatables.extended.config" placeholder="before_start_document_ready" />
  </datatables:table>
  <br/>
  <br/>
</body>

</html>
