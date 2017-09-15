<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="LiNuoMes.Login.Login" %>


<html xmlns="http://www.w3.org/1999/xhtml">

<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<title>系统登录</title>

<link href="../css/login.css" rel="stylesheet" />
<link href="../css/demo.css" rel="stylesheet" />
<script src="../Content/scripts/jquery-1.11.1.min.js"></script>
<link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
<link rel="Shortcut icon" href="../images/favicon.ico" />
<link href="../Content/styles/learun-ui.css" rel="stylesheet" /> 
<script src="../Content/scripts/plugins/dialog/dialog.js"></script>
<script src="../Content/scripts/utils/learun-ui.js"></script>
<script src="../Content/scripts/utils/learun-form.js"></script>
<script src="../js/Validform_v5.3.2_min.js"></script>
    
<script>

    $(function () {
        $(".i-text").focus(function () {

            $(this).addClass('h-light');

        });


        $(".i-text").focusout(function () {

            $(this).removeClass('h-light');

        });

        $("#username").focus(function () {

            var username = $(this).val();

            if (username == '输入账号') {

                $(this).val('');

            }

        });

        $("#username").focusout(function () {

            var username = $(this).val();

            if (username == '') {

                $(this).val('输入账号');

            }

        });

        $(".registerform").Validform({

            tiptype: function (msg, o, cssctl) {

                var objtip = $(".error-box");

                cssctl(objtip, o.type);

                objtip.text(msg);
            },
            ajaxPost: true

        });

        $("#sky").animate({ opacity: 1.0 });
        
        $("#flashdownload").click(function () {
            //var userAgent = navigator.userAgent;
            //var currentAgent = '';
            //if (userAgent.indexOf("Firefox") > -1) {
            //    currentAgent= "Firefox";
            //}
            //if (userAgent.indexOf("Chrome") > -1) {
            //    if (window.navigator.webkitPersistentStorage.toString().indexOf('DeprecatedStorageQuota') > -1) {
            //        currentAgent= "Chrome";
            //    } else {
            //        currentAgent= "360";
            //    }
            //}
            
            //if (userAgent.indexOf("compatible") > -1 && userAgent.indexOf("MSIE") > -1 && !isOpera) {
            //    currentAgent= "IE";
            //};
            
            var Action = "DownFlash";
            postAndRedirect("../Login/EditPassword.ashx?Action=" + Action, { CurrentAgent: $.isbrowsername() });
        }).hover(function () {
            $("#flashdownload").css("cursor", "pointer");
        })
    });

    //登录
    function login() {

        //if (!$('#form1').Validform()) {
        //    return false;
        //}
        var userid = $('#username').val().replace("'", "''");
        var psw = $('#password').val();
        $.ajax({
            url: "Login.aspx/CheckLogin",
            data: "{UserID:\"" + userid + "\",Password:'" + psw + "'}",
            type: "post",
            dataType: "json",
            contentType: "application/json;charset=utf-8",
            success: function (data) {
                if (data.d == "success") { 
                    Loading(false);
                    dialogMsg("登录成功", 1);
                    location.href = "../LineMonitor/LineMonitorMan.aspx";
                    
                }
                else if (data.d == "nouser") {
                    dialogMsg("用户名不正确", -1);
                }
                else if (data.d == "errorpsw") {
                    dialogMsg("密码不正确", -1);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                Loading(false);
                dialogMsg(errorThrown, -1);
            },
            beforeSend: function () {
                Loading(true, "正在登录中");
            },
            complete: function () {
                Loading(false);
            }
        });
        
    }

    function postAndRedirect(url, postData) {
        //  Redirect to a URL, and POST some data to it.
        //  Taken from:
        //  http://stackoverflow.com/questions/8389646/send-post-data-on-redirect-with-javascript-jquery
        //
        var postFormStr = "<form method='POST' action='" + url + "'>\n";

        for (var key in postData) {
            if (postData.hasOwnProperty(key)) {
                postFormStr += "<input type='hidden' name='" + key + "' value='" + postData[key] + "'></input>";
            }
        }

        postFormStr += "</form>";

        var formElement = $(postFormStr);

        $('body').append(formElement);
        $(formElement).submit();
    }

</script>

</head>
<body style="background-color: #f4fbfd; background-image: url(../images/bg.png); background-repeat: repeat-x;">
<div class="header" >

  <h1 class="headerLogo"><a title="后台管理系统" target="_blank"><img alt="logo" id="sky" src="../images/logo.jpg"></a></h1>

	<div class="headerNav">

		<a target="_blank" href="http://www.linuo-paradigma.com/">力诺瑞特官网</a>

		<a target="_blank">关于力诺瑞特</a>

		<a target="_blank">开发团队</a>

		<a target="_blank" id="flashdownload">FLASH插件</a>

		   
	</div>

</div>

<div class="banner">

<div class="login-aside">

  <div id="o-box-up"></div>

  <div id="o-box-down"  style="table-layout:fixed;">

  <%-- <div class="error-box"></div>--%>

   <form class="registerform">

   <div class="fm-item">
	   <label for="logonId" class="form-label">MES系统登陆：</label>
	   <%--<input type="text" value="输入账号" maxlength="100" id="username" class="i-text" ajaxurl="demo/valid.jsp"  datatype="s6-18" errormsg="用户名至少6个字符,最多18个字符！"  > --%> 
       <input type="text" value="输入账号" maxlength="100" id="username" class="i-text">  
       <div class="ui-form-explain"></div>

  </div>

  <div class="fm-item">
	   <label for="logonId" class="form-label">登陆密码：</label>
	   <%--<input type="password" value="" maxlength="100" id="password" class="i-text" datatype="*6-16" nullmsg="请设置密码！" errormsg="密码范围在6~16位之间！"> --%>   
      <input type="password" value="" maxlength="100" id="password" class="i-text">
       <div class="ui-form-explain"></div>
  </div>

  <div class="fm-item">
	   <label for="logonId" class="form-label"></label>
	   <input type="submit" value="" tabindex="4" id="send-btn" class="btn-login" onclick="login()"> 
       <div class="ui-form-explain"></div>
  </div>
  </form>
  </div>
</div>

	<div class="bd">
		<ul>
			<li style="background:url(../images/theme-pic1.jpg) #CCE1F3 center 0 no-repeat;"><a target="_blank" ></a></li>

		</ul>

	</div>

	<div class="hd"><ul></ul></div>

</div>

</body>

</html>

