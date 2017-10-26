(function ($) {
    $.learunindex = {
        load: function () {
            $(window).load(function () {
                window.setTimeout(function () {
                    $('#ajax-loader').fadeOut();
                    Loading(false);
                }, 300);
            });
        },
        jsonWhere: function (data, action) {
            if (action == null) return;
            var reval = new Array();
            $(data).each(function (i, v) {
                if (action(v)) {
                    reval.push(v);
                }
            })
            return reval;
        },
        loadMenu: function () {
            var _html = '<div class="container m0" style="position:relative;">';
            var _html1 = '<div class="container-fluid">';
            _html1 += '<div id="n1" class="nav-zi ty" style="display: none;">';
            $.ajax({
                url: "../Login/fMenu.aspx/GetMenuList",
                type: "post",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    $.each(data.d, function (i) {
                        var row = data.d[i];
                        if (row.parentno == "0000") {
                            _html += '<a class="nzz"  id="' + row.menuno + '"><span class="sort"><i class="' + row.img + '"></i>&nbsp;' + row.menuname + '<i class="fa fa-angle-down"></i> </span></a>|';
                            var childNodes = $.learunindex.jsonWhere(data.d, function (v) { return v.parentno == row.menuno });
                            if (childNodes.length > 0) {
                                _html1 += '<ul id="n' + row.menuno + '" class="nn list-inline container m0" style="display: none;">';
                                $.each(childNodes, function (i){
                                    var subrow = childNodes[i];
                                    if (subrow.url=="") {
                                        subrow.url = "javascript:void(0);";
                                    }
                                    _html1 += ' <li><a class="c-btn c-btn--border-line" href="' + subrow.url + '"><i class="' + subrow.img + '"></i>' + subrow.menuname + '</a></li>';
                                })
                                _html1 += '</ul>';
                               
                            }
                        }  
                    })
                    _html += ' </div>';
                    _html1 += '</div>';
                    _html1 += '</div>';
                    $("#menu_wrap").append(_html);
                    $("#menu_wrap").append(_html1);
                    var sz = {};
                    var zid;
                    var pd1 = 0;
                    var pd2 = 0;
                    $('.c-btn.c-btn--border-line').click(function () {
                        var url = $(this).attr('href');
                        var urlname = $(this).text();
                        if(url=='#'){
                            dialogMsg("您没有权限操作:" + urlname, -1);
                        }
                        if (url == 'javascript:void(0);') {
                            dialogMsg( urlname+"页面未完成", 0);
                        }
                    });
                    $(".nzz").hover(function () {
                        zid = $(this).attr('id');
                        sz[zid + '_timer'] = setTimeout(function () {
                            $('#areascontent').addClass('mh');
                            $(".nn").css("display", "none");
                            $(".nav-zi").css("display", "block");
                            $("#n" + zid).css("display", "block");
                            $("#n" + zid).addClass("nadc");
                            $(".nzz").removeClass("nav-zibg");
                            $("#" + zid).addClass("nav-zibg");
                            pd1 = 1;
                        }, 300);
                    },
                    function () {
                        clearTimeout(sz[zid + '_timer']);
                    });

                    $(".yn").mouseleave(function () {
                        $(".nav-zi").css("display", "none");
                        $('#areascontent').removeClass('mh');
                        $(".nzz").removeClass("nav-zibg");

                    });
                   
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    dialogMsg(errorThrown, -1);
                }
            });
            

        },
        loadNav:  function (){
            var html = '<div class="container-fluid">';
            html+='<div class="container-fluid">';
            html+='<div class="navbar-header">';
            html+='<span style="font-weight: bold;line-height: 50px;text-shadow: 3px 3px 7px #000;color: #ffffff;"><strong style="font-size: 30px;text-align: center;padding: 3px;margin: 0px;">力诺瑞特平板集热器MES系统</strong></span>';   
            html+='</div><div id="navbar" class="navbar-collapse collapse">';  
            html+=' <ul class="nav navbar-nav navbar-right"><li><div class="myhome"><div class="xyd"><i class="fa fa-bell-o" aria-hidden="true"></i></div>';
            html += ' <span class="hidden-xs" id="username"></span>';
            html += ' <span class="hidden-xs" id="userid"  hidden="hidden"></span>';
            html+=' <img src="/Content/images/head/user2-160x160.jpg" class="user-image" alt="User Image">';
            html += '<div class="myhome-z bh2"><a class="bh" href="#" id="btn_userinfo"><i class="fa fa-user"></i>个人信息</a><a class="bh" href="#" id="btn_editpsw"><i class="fa fa-home"></i> 修改密码</a><a class="bh" href="#" id="btn_out"><i class="fa fa-sign-out"></i> 退出登录</a></div>';
            html+=' </div></li></ul></div></div>';        
            $("#nav").append(html);
            $.ajax({
                type: "POST",
                url: "../../Login/Login.aspx/GetSession",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    document.getElementById("username").innerText = data.d;
                },
                error: function (data) {

                }
            })

            $.ajax({
                type: "POST",
                url: "../../Login/Login.aspx/GetUserID",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    document.getElementById("userid").innerText = data.d;
                },
                error: function (data) {

                }
            })
            $("#btn_userinfo").click(function (event) {
                var userid = document.getElementById("userid").innerText;
                dialogOpen({

                    id: "Form",
                    title: '个人信息',
                    url: '../UserManage/UserProcessCodeEdit.aspx',
                    data: { UserID: userid },
                    width: "750px",
                    height: "400px",
                    callBack: function (iframeId) {
                        top.frames[iframeId].AcceptClick();
                    }
                });

            })

            $("#btn_editpsw").click(function (event) {
                dialogOpen({
                    id: "Form",
                    title: '修改密码',
                    url: '../Login/EditPsw.aspx',
                    width: "750px",
                    height: "400px",
                    callBack: function (iframeId) {
                        top.frames[iframeId].AcceptClick();
                    }
                });
                
            })
            $("#btn_out").click(function (event) {
                dialogConfirm("注：您确定要安全退出本次登录吗？", function (r) {
                    if (r) {
                        Loading(true, "正在安全退出...");
                        window.setTimeout(function () {
                            window.location.href = "../Login/Login.aspx";
                        }, 500);
                    }
                });

            })
        },
        getsession: function () {
           
        },
        loadloading: function (){
            var htmlload = '<div id="loading_background" class="loading_background" style="display: none;"></div><div id="loading_manage" style="display: none;">正在拼了命为您加载…</div>';
            $("body").append(htmlload);
        }
    };
    $(function () {
        $.learunindex.load();
        $.learunindex.loadNav();
        $.learunindex.loadMenu();
        $.learunindex.loadloading();
    });
})(jQuery);