<%@ page language="java" 
	import="java.util.*" 
	import="java.sql.*" 
	import="chingoo.oracle.*" 
	contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
%>

<%
	Connect cn = (Connect) session.getAttribute("CN");

//	String searchKey = request.getParameter("searchKey");
//	if (searchKey != null) searchKey = searchKey.trim();
%>
<%
	TriggerTableWorker ttw = cn.triggerTableWorker;
	List<String> tables = ttw.startWork(cn);
%>
