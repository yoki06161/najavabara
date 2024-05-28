<%@page import="java.sql.Timestamp"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="dao.friendReplyDAO"%>
<%@page import="dto.friendReplyDTO"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="dto.friendCommentDTO"%>
<%@ page import="java.util.Set"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시물 상세보기</title>
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<style>
.rounded-image {
	border-radius: 15px; /* 이미지의 모서리를 둥글게 만듦 */
}
</style>
<script>
    function confirmDelete(postNum) {
        if (confirm("게시물을 삭제하시겠습니까?")) {
            window.location.href = "deletePost.fri?num=" + postNum;
        }
    }

    function confirmDeleteComment(commentNum, postNum) {
        if (confirm("댓글을 삭제하시겠습니까?")) {
            window.location.href = "deleteComment.co?commentNum=" + commentNum + "&postNum=" + postNum;
        }
    }

    function confirmDeleteReply(replyNum, postNum) {
        if (confirm("답글을 삭제하시겠습니까?")) {
            window.location.href = "deleteReply.re?replyNum=" + replyNum + "&postNum=" + postNum;
        }
    }

    function showReplyForm(commentNum, event) {
        var form = document.getElementById("replyForm_" + commentNum);
        form.style.display = "block";
        event.preventDefault();
    }

    function hideReplyForm(commentNum) {
        var form = document.getElementById("replyForm_" + commentNum);
        form.style.display = "none";
    }

    var likeInProgress = false; // 클릭 이벤트가 실행 중인지 여부를 나타내는 변수

    function toggleLike(postNum, event) {
        if (likeInProgress) return; // 클릭 이벤트가 이미 실행 중이면 더 이상 실행하지 않음
        likeInProgress = true; // 클릭 이벤트가 실행 중임을 표시

        $.ajax({
            url: "likePost.fri",
            type: "POST",
            data: { num: postNum },
            success: function(response) {
                // 서버로부터 좋아요 수를 받아와서 업데이트합니다.
                $("#likeCount").text(response.likeCount);
            },
            error: function() {
                alert("좋아요 처리 중 오류가 발생했습니다.");
            },
            complete: function() {
                likeInProgress = false; // 클릭 이벤트가 완료되었으므로 변수를 초기화
            }
        });

        event.preventDefault(); // 링크 클릭 이벤트의 기본 동작을 막음

        return false;
    }
    
    var commentInProgress = false; // 댓글 작성 요청이 진행 중인지 여부를 나타내는 변수

    function submitComment() {
        if (commentInProgress) return false; // 댓글 작성 요청이 이미 진행 중이면 제출을 막음
        commentInProgress = true; // 댓글 작성 요청이 진행 중임을 표시

        // 댓글 작성 버튼 가져오기
        var submitButton = document.getElementById("commentSubmit");

        // 댓글 작성 버튼 비활성화
        submitButton.disabled = true;

        // 폼 제출
        return true;
    }
    
    var replyInProgress = {}; // 댓글별로 답글 작성 요청이 진행 중인지 여부를 나타내는 객체

    function submitReply(commentNum) {
        if (replyInProgress[commentNum]) return false; // 답글 작성 요청이 이미 진행 중이면 제출을 막음
        replyInProgress[commentNum] = true; // 답글 작성 요청이 진행 중임을 표시

        // 답글 작성 버튼 가져오기
        var submitButton = document.getElementById("replySubmit_" + commentNum);

        // 답글 작성 버튼 비활성화
        submitButton.disabled = true;

        // 폼 제출
        return true;
    }
</script>
</head>
<body>
	<%@ include file="../common/menu.jsp"%>
	<div class="container mt-5">
		<h2 class="mb-4">게시물 상세보기</h2>

		<%
		if (request.getAttribute("post") != null) {
			dto.friendBoardDTO post = (dto.friendBoardDTO) request.getAttribute("post");
			dto.UserDTO user = (dto.UserDTO) session.getAttribute("user");
			boolean isOwner = (user != null && user.getId().equals(post.getId()));
		%>
		<div class="card">
			<div class="card-header">
				<h5 class="card-title"><%=post.getTitle()%></h5>
			</div>
			<div class="card-body">
				<p class="card-text">
					작성자:
					<%=post.getId()%>
					<small class="text-muted"> <%-- 작성일시를 더 보기 쉬운 형식으로 표시 --%>
						<%
						LocalDateTime postDateTime = post.getPostdate().toLocalDateTime();
						%> <%=postDateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))%>
					</small>
				</p>
				<p class="card-text">
					조회수:
					<%=post.getVisitcount()%>
				</p>
				<p class="card-text">
					내용:
					<%=post.getContent()%>
				</p>
				<%
				if (post.getFileNames() != null && !post.getFileNames().isEmpty()) {
							for (int i = 0; i < post.getFileNames().size(); i++) {
								String fileName = post.getFileNames().get(i);
								String filePath = "uploads/" + fileName;
								// 이미지 파일인지 확인
								boolean isImage = fileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif)$");
								if (isImage) {
				%>
				<div class="mt-3">
					<img src="<%=filePath%>" alt="첨부 이미지"
						class="img-fluid rounded-image">
				</div>
				<%
				} else {
				%>
				<div class="mt-3">
					<p>
						첨부 파일: <a href="download.fri?fileName=<%=fileName%>&ofileName=<%=post.getOfileNames().get(i)%>"><%=post.getOfileNames().get(i)%></a>
					</p>
				</div>
				<%
				}
						}
						}
				%>
			</div>
		</div>
		<div class="mt-3">
			<a href="friendBoard.fri" class="btn btn-primary me-2">게시판으로 돌아가기</a>
			<%
			if (isOwner) {
			%>
			<a href="editPostForm.fri?num=<%=post.getNum()%>"
				class="btn btn-primary me-2">게시물 수정</a> <a href="#"
				class="btn btn-danger" onclick="confirmDelete(<%=post.getNum()%>)">게시물
				삭제</a>
			<%
			}
			%>
		</div>

		<hr>

		<%
		List<friendCommentDTO> commentList = (List<friendCommentDTO>) request.getAttribute("commentList");
				int commentCount = commentList != null ? commentList.size() : 0;
		%>

		<p>
			<button type="button" class="btn btn-primary me-2"
				onclick="toggleLike(<%=post.getNum()%>)">
				좋아요 <span id="likeCount"><%=request.getAttribute("likeCount")%></span>
			</button>
			<span>댓글 <%=commentCount%></span>
		</p>
		<h4 class="mt-4">댓글</h4>
		<%
		if (commentList != null && !commentList.isEmpty()) {
			for (friendCommentDTO comment : commentList) {
				boolean isCommentOwner = (user != null && user.getId().equals(comment.getWriter()));
				friendReplyDAO replyDAO = new friendReplyDAO();
				List<friendReplyDTO> replyList = replyDAO.getRepliesByCommentNum(comment.getCommentNum());
		%>
		<div class="card mt-2">
			<div class="card-body">
				<p class="card-text">
					<%=comment.getWriter()%>
					<%
					if (post.getId().equals(comment.getWriter())) {
					%>
					<span class="badge badge-secondary">작성자</span>
					<%
					}
					%>
					<small class="text-muted"><%=comment.getRegDate()%></small>
					<%
					if (isCommentOwner) {
					%>
					<a href="#" class="btn btn-sm btn-danger ms-2"
						onclick="confirmDeleteComment(<%=comment.getCommentNum()%>, <%=post.getNum()%>)">삭제</a>
					<%
					}
					%>
					<a href="#" class="btn btn-sm btn-secondary ms-2"
						onclick="showReplyForm(<%=comment.getCommentNum()%>, event)">답글
						작성</a>
				</p>
				<p class="card-text">
					<%=comment.getComment()%>
				</p>
				<div id="replyForm_<%=comment.getCommentNum()%>"
					style="display: none;">
					<form id="replyForm_<%=comment.getCommentNum()%>"
						action="writeReply.re" method="post"
						onsubmit="return submitReply(<%=comment.getCommentNum()%>)">
						<div class="form-group">
							<textarea class="form-control"
								id="reply_<%=comment.getCommentNum()%>" name="reply" rows="2"
								required></textarea>
						</div>
						<input type="hidden" name="postNum" value="<%=post.getNum()%>">
						<input type="hidden" name="commentNum"
							value="<%=comment.getCommentNum()%>"> <input
							type="hidden" name="writer"
							value="<%=user != null ? user.getName() : ""%>">
						<button type="submit"
							id="replySubmit_<%=comment.getCommentNum()%>"
							class="btn btn-primary btn-sm">등록</button>
						<button type="button" class="btn btn-secondary btn-sm ms-2"
							onclick="hideReplyForm(<%=comment.getCommentNum()%>)">취소</button>
					</form>
				</div>

				<%
				if (replyList != null && !replyList.isEmpty()) {
					for (friendReplyDTO reply : replyList) {
						boolean isReplyOwner = (user != null && user.getId().equals(reply.getWriter()));
				%>
				<div class="card mt-2">
					<div class="card-body">
						<p class="card-text">
							<%=reply.getWriter()%>
							<%
							if (post.getId().equals(reply.getWriter())) {
							%>
							<span class="badge badge-secondary">작성자</span>
							<%
							}
							%>
							<small class="text-muted"><%=reply.getRegDate()%></small>
							<%
							if (isReplyOwner) {
							%>
							<a href="#" class="btn btn-sm btn-danger ms-2"
								onclick="confirmDeleteReply(<%=reply.getReplyNum()%>, <%=post.getNum()%>)">삭제</a>
							<%
							}
							%>
						</p>
						<p class="card-text">
							<%=reply.getReply()%>
						</p>
					</div>
				</div>
				<%
				}
				}
				%>
			</div>
		</div>
		<%
		}
		} else {
		%>
		<p>댓글이 없습니다.</p>
		<%
		}
		%>
		<div class="mt-4">
			<form id="commentForm" action="writeComment.co" method="post"
				onsubmit="return submitComment()">
				<div class="form-group">
					<label for="comment">댓글 작성</label>
					<textarea class="form-control" id="comment" name="comment" rows="3"
						required></textarea>
				</div>
				<input type="hidden" name="postNum" value="<%=post.getNum()%>">
				<input type="hidden" name="writer"
					value="<%=user != null ? user.getName() : ""%>">
				<button type="submit" id="commentSubmit" class="btn btn-primary">등록</button>
			</form>
		</div>
		<%
		} else {
		%>
		<p>게시물이 존재하지 않습니다.</p>
		<%
		}
		%>
	</div>
</body>
</html>
