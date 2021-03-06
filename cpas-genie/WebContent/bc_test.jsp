<%@ page language="java" 
	import="java.util.*" 
	import="java.util.Date" 
	import="java.sql.*" 
	import="spencer.genie.*" 
	import="oracle.jdbc.OracleTypes"
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%!

public String getBC(Connection conn, String fname, String type) {
	String res="";
	if (conn != null) {

	    String cStmt = "{ ? = call " + fname+" }";
	    //Util.p(cStmt);
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
	    	if (type.equals("BOOLEAN")) {
				oStmt.registerOutParameter(1, OracleTypes.BOOLEAN);
		        oStmt.execute();
				res = oStmt.getString(1);
				//res = (b?"true":"false");
	    	} else {
				oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
		        oStmt.execute();
		        res = oStmt.getString(1);
	    	}
		        
	        

	    } catch (SQLException e) {
			Util.p("*** " + fname);
			res = "ERROR: " + e.getMessage();
	        e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
	        
	}
	
	return res;
}

public String getBCParameter(Connection conn, String param, String datatype) {
	String res="";
	if (conn != null) {

		String fname="";
		if (datatype.equals("D")) fname = "BC_PARAMETER.getDate";
		if (datatype.equals("N")) fname = "BC_PARAMETER.getNum";
		if (datatype.equals("C")) fname = "BC_PARAMETER.getChar";
		
	    String cStmt = "{ ? = call " + fname+"(?) }";
	    //Util.p(cStmt);
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
			oStmt.setString(2,param);
	        oStmt.execute();
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
			Util.p("**** " + fname);
			res = "ERROR: " + e.getMessage();
	        e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
	        
	}
	
	return res;
}


public String getBCBoolean(Connection conn, String fname) {
	String res="";
	if (conn != null) {

	    //String cStmt = "{ ? = call " + fname+" }";
        String cStmt = "" +
        " declare " +  
        "    cRes varchar2(20) := '';" +
        "    lRes boolean;" +
        " begin " +
        "    lRes := " + fname + ";" +
        "    if lRes = true then cRes := 'true'; end if;" +
        "    if lRes = false then cRes := 'false'; end if;" +
        "    ? := cRes;" +
        " end;";
		
	    //Util.p(cStmt);
	    CallableStatement oStmt=null;
	    int nResult = 0;
	    
	    try {
	    	oStmt = conn.prepareCall(cStmt);
			oStmt.registerOutParameter(1, OracleTypes.VARCHAR);
	        oStmt.execute();
	        res = oStmt.getString(1);

	    } catch (SQLException e) {
			Util.p("*** " + fname);
			res = "ERROR: " + e.getMessage();
	        e.printStackTrace();
	    } finally {
		    try {
		    	if (oStmt != null)
				    oStmt.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    }
	        
	}
	
	return res;
}
%>
<%
	Connect cn = (Connect) session.getAttribute("CN");
	String calcid = Util.nvl(request.getParameter("calcid"));
	if (calcid.equals("")) {
		calcid = cn.queryOne("SELECT MAX(calcid) FROM CALC");
	}
	
	String clnt=null;
	String plan=null;
	if (!calcid.equals("")) {
		clnt = cn.queryOne("SELECT CLNT FROM CALC WHERE CALCID="+calcid);
		plan = cn.queryOne("SELECT PLAN FROM CALC WHERE CALCID="+calcid);
	}
	
%>
<html>
<head> 
	<title>BenCalc Test</title>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /> 

    <script src="script/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="script/genie.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>
    <script src="script/data-methods.js?<%= Util.getScriptionVersion() %>" type="text/javascript"></script>

    <link rel='stylesheet' type='text/css' href='css/style.css?<%= Util.getScriptionVersion() %>'>
	<link rel="icon" type="image/png" href="image/Genie-icon.png">

	<link rel="stylesheet" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" type="text/css"/>
	<script src="script/jquery-ui-1.8.18.custom.min.js" type="text/javascript"></script>

	<style>
	.ui-autocomplete-loading { background: white url('image/ui-anim_basic_16x16.gif') right center no-repeat; }
.ui-autocomplete {
		max-height: 500px;
		overflow-y: auto;
		/* prevent horizontal scrollbar */
		overflow-x: hidden;
		/* add padding to account for vertical scrollbar */
		padding-right: 20px;
	}
	/* IE 6 doesn't support max-height
	 * we use height instead, but this forces the menu to always be this tall
	 */
	* html .ui-autocomplete {
		height: 500px;
	}	
	</style>
	    
	<script type="text/javascript">
	$(function() {
		$( "#globalSearch" ).autocomplete({
			source: "ajax/auto-complete2.jsp",
			minLength: 2,
			select: function( event, ui ) {
				popObject( ui.item ?
					ui.item.value: "" );
			}
		}).data( "autocomplete" )._renderItem = function( ul, item ) {
			return $( "<li></li>" )
			.data( "item.autocomplete", item )
			.append( "<a>" + item.label + " <span class='rowcountstyle'>" + item.desc + "</span></a>" )
			.appendTo( ul );
		};
	});	
	function popObject(oname) {
		$("#popKey").val(oname);
    	$("#FormPop").submit();
	}
	    
	function loadProc(pkgName, prcName) {
		$("#name-map").val(pkgName+"."+prcName);
		$("#form-map").submit();
	}	

    </script>
    
</head> 

<body>
<%
	String id = Util.getId();
%>

<div style="background-color: #E6F8E0; padding: 6px; border:1px solid #CCCCCC; border-radius:10px;">
<img src="image/star-big.png" width=20 height=20 align="top"/>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">BenCalc Test</span>
 
&nbsp;&nbsp;
<b><%= cn.getUrlString() %></b>

&nbsp;&nbsp;&nbsp;&nbsp;

<a href="Javascript:hideNullColumn()">Hide Null</a> |
<a href="Javascript:newQry()">Pop Query</a> |
<a href="query.jsp" target="_blank">Query</a> |
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<!-- <a href="Javascript:openWorksheet()">Open Work Sheet</a>
 -->
<span style="float:right;">
Search <input id="globalSearch" style="width: 200px;" placeholder="table or view name"/>
</span>
</div>

<br/>

<form method="get">
Calc ID <input name="calcid" value="<%= calcid %>" size=10>

<input type="submit" value="Run"> 
</form>

<hr>

<% if (!calcid.equals("")) {
	id = Util.getId();
	String sql= "SELECT * FROM CALC WHERE CALCID="+calcid; 
%>
<div style="display: none;" id="sql-<%=id%>"><%= sql%></div>
<div style="display: none;" id="mode-<%=id%>">hide</div>
<div style="display: none;" id="ori-<%=id%>">H</div>
<div style="display: none;" id="hide-<%=id%>"></div>
<div id="div-<%=id%>">
<jsp:include page='ajax/qry-simple.jsp'>
	<jsp:param value='<%= sql %>' name="sql"/>
	<jsp:param value="1" name="dataLink"/>
	<jsp:param value="<%= id %>" name="id"/>
</jsp:include>
</div>
<br/>
<% } %>

<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">BenCalc Functions</span>
<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 20px;">
<tr>
	<th class="headerRow">Package</th>
	<th class="headerRow">Function</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Value</th>
</tr>
<%
	if (!calcid.equals("")) {
		cn.bcSetAll(calcid);
/*		
		String q = "select object_name, procedure_name from( "+
				"SELECT a.*,(select count(*) from user_arguments where object_id=a.object_id and subprogram_id=a.subprogram_id) cnt " +
				"FROM user_procedures a WHERE OBJECT_NAME LIKE 'BC%' and PROCEDURE_NAME like 'GET%') where cnt=1 order by 1, 2";
*/
String q = "select package_name, object_name, pls_type from user_arguments a where package_name like 'BC%' and (object_name like 'GET%' OR object_name like 'IS%') " +
	"and not exists (select 1 from user_arguments b where object_id=a.object_id and subprogram_id=a.subprogram_id and position=1) and pls_type !='BOOLEAN-' " +
	"order by package_name, object_name, position";

if (cn.getTargetSchema() != null) {
	q = "select package_name, object_name, pls_type from all_arguments a where owner='"+cn.getTargetSchema()+"' and package_name like 'BC%' and (object_name like 'GET%' OR object_name like 'IS%') " +
			"and not exists (select 1 from all_arguments b where object_id=a.object_id and subprogram_id=a.subprogram_id and position=1) and pls_type !='BOOLEAN-' " +
			"order by package_name, object_name, position";
}

		List<String[]> ff = cn.query(q, false);

		int rowCnt=0;
		for (String[] fl: ff) {
			if (fl[2].endsWith("INSTANCE")) continue;
			
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";
//Util.p("plstype=" + fl[3]);			
			String fname = fl[1]+ "." + fl[2];
			String value = "";
			if (fl[3].equals("BOOLEAN"))
				value = getBCBoolean(cn.getConnection(), fname);
			else
			 	value = getBC(cn.getConnection(), fname, fl[3]);
			if (value==null) value="";
			String tooltip = null;
			if (value.startsWith("ERROR")) {
				tooltip = value;
				value = "ERROR";
			}
			String align="left";
			if (fl[3].equals("NUMBER")||fl[3].equals("PLS_INTEGER")) align="right";
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= fl[1] %></td>
	<td class="<%= rowClass%>"><%= cn.getProcedureLabel(fl[1], fl[2])  %></td>
	<td class="<%= rowClass%>"><%= fl[3] %></td>
	<td class="<%= rowClass%>" align="<%= align %>">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title="<%=tooltip%>"><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
		
	</td>
</tr>
<%			
		}
		
		
	}
%>
</table>

<br/>
<%
	id = Util.getId();
%>
<span style="color: blue; font-family: Arial; font-size:16px; font-weight:bold;">Parameters</span>
<table id="table-<%= id %>" border=1 class="gridBody" style="margin-left: 20px;">
<tr>
	<th class="headerRow">Parameter</th>
	<th class="headerRow">Type</th>
	<th class="headerRow">Value</th>
	<th class="headerRow">Reamrk</th>
</tr>
<%
String q = "select param, datatype, remark from CPAS_PARAMETER order by 1";

		List<String[]> ff = cn.query(q, false);

		int rowCnt=0;
		for (String[] fl: ff) {
			rowCnt++;
			String rowClass = "oddRow";
			if (rowCnt%2 == 0) rowClass = "evenRow";

			String param = fl[1];
			String datatype = fl[2];
			String remark = fl[3];
			String value = "";
			value = getBCParameter(cn.getConnection(), param, datatype);
			if (value==null) value ="";
			
			String tooltip = null;
			if (value != null && value.startsWith("ERROR")) {
				tooltip = value;
				value = "ERROR";
			}
%>
<tr class="simplehighlight">
	<td class="<%= rowClass%>"><%= param %></td>
	<td class="<%= rowClass%>"><%= datatype %></td>
	<td class="<%= rowClass%>">
	<% if (tooltip != null) {%>
		<span class="pk2"><a title="<%=tooltip%>"><%= value %></a></span>
	<% } else {  %>
		<span class="pk"><%= value %></span>
	<% } %>
	
	</td>
	<td class="<%= rowClass%>"><%= remark %></td>
	</td>
</tr>
<%			
	}
%>

</table>

<form id="FormPop" name="FormPop" target="_blank" method="post" action="pop.jsp">
<input id="popType" name="type" type="hidden" value="OBJECT">
<input id="popKey" name="key" type="hidden">
</form>

<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= Util.trackingId() %>']);
  _gaq.push(['_setDomainName', 'none']);
  _gaq.push(['_trackPageview']);
  
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

<form id="FORM_query" name="FORM_query" action="query.jsp" target="_blank" method="post">
<input id="sql-query" name="sql" type="hidden"/>
</form>
<form name="form-map" id="form-map" action="package-tree.jsp" target="_blank" method="get">
<input id="name-map" name="name" type="hidden">
</form>

</body>
</html>

