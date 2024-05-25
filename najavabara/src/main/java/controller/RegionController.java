package controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import com.oreilly.servlet.MultipartRequest;

import dao.RegionDAO;
import dto.RegionDTO;



@WebServlet("*.reg")
public class RegionController extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doProcess(request, response);
	}

	protected void doProcess(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		/// join.jsp? login.jsp? joinProc?
		System.out.println("doProcess");
		request.setCharacterEncoding("utf-8"); // 한글처리

		String uri = request.getRequestURI();
		String action = uri.substring(uri.lastIndexOf("/"));
		System.out.println(uri);

		if(action.equals("/list.reg")) {
			System.out.println(action);

			String searchField = request.getParameter("searchField");
			String searchWord = request.getParameter("searchWord");

			Map<String, String> map = new HashMap<>();
			map.put("searchField", searchField);
			map.put("searchWord", searchWord);

			// service : dao
			RegionDAO dao = new RegionDAO();
			List<RegionDTO> regionList =  dao.selectList(map);
			int totalCount = dao.selectCount(map);

			request.setAttribute("regionList", regionList);
			request.setAttribute("totalCount", totalCount);

			String path =  "./list.jsp"; // 1
			request.getRequestDispatcher(path).forward(request, response);

		}else if(action.equals("/view.reg")) {
			// 값 받아오기
			request.setCharacterEncoding("utf-8");
			String sNum = request.getParameter("num"); 
			int num = Integer.parseInt(sNum);
			RegionDTO dto = new RegionDTO();
			dto.setNum(num);
			//System.out.print(num);  //찍히는 것 확인...

			RegionDAO dao = new RegionDAO();

			//1. 조회수 update
			dao.updateVisitcount(dto); // 5초
			//2. 글 상세보기
			dto = dao.selectView(dto);

			request.setAttribute("dto", dto);

			//3. forward
			String path =  "./view.jsp"; // 1
			request.getRequestDispatcher(path).forward(request, response);
		}else if(action.equals("/write.reg")) {
			String path = request.getContextPath() + "/region/write.jsp";
			response.sendRedirect(path);
		}else if(action.equals("/writeProc.reg")) {
			// 값 한글처리
			request.setCharacterEncoding("utf-8");

			String saveDirectory = "C:/Users/TJ/git/NAJAVABARA/najavabara/src/main/webapp/Uploads";
			System.out.println(saveDirectory);
			String encoding = "UTF-8";
			int maxPostSize = 1024 * 1000 * 10; // 1000kb -> 1M > 10M

			MultipartRequest mr = new MultipartRequest(request, saveDirectory, maxPostSize, encoding);

			String fileName = mr.getFilesystemName("file");
			String ext = fileName.substring(fileName.lastIndexOf("."));
			String now = new SimpleDateFormat("yyyyMMdd_HmsS").format(new Date());
			String newFileName = now + ext;
			System.out.println(fileName);
			System.out.println(newFileName);

			File oldFile = new File(saveDirectory + File.separator + fileName); 
			File newFile = new File(saveDirectory + File.separator + newFileName); 
			oldFile.renameTo(newFile);

			// 나머지 값 받아오기			
			String title = mr.getParameter("title");
			String content = mr.getParameter("content");
			HttpSession session = request.getSession();    
			String id = (String)session.getAttribute("id");

			RegionDTO dto = new RegionDTO(title, content, id);
			dto.setOfile(fileName);
			dto.setSfile(newFileName);

			System.out.println(title);
			System.out.println(content);
			System.out.println(id);

			// 4. DAO 
			RegionDAO dao = new RegionDAO();
			dao.insertWrite(dto);

			// 5. move
			String path = request.getContextPath() + "/region/list.reg";
			response.sendRedirect(path);
		}else if(action.equals("/update.reg")) {
			// 값 받아오기
			request.setCharacterEncoding("utf-8");
			String sNum = request.getParameter("num"); 
			int num = Integer.parseInt(sNum);	

			// 게시물 데이터 불러오기
			RegionDTO dto = new RegionDTO();
			dto.setNum(num);

			RegionDAO dao = new RegionDAO();
			RegionDTO reg = dao.selectView(dto);

			request.setAttribute("reg", reg);

			//3. forward
			String path =  "./update.jsp"; // 1
			request.getRequestDispatcher(path).forward(request, response);
		}else if(action.equals("/updateProc.reg")) {
			// 값 받기
			request.setCharacterEncoding("utf-8");
			String sNum = request.getParameter("num"); 
			int num = Integer.parseInt(sNum);	
			String title = request.getParameter("title");
			String content = request.getParameter("content");

			//DTO
			RegionDTO dto = new RegionDTO();	
			dto.setNum(num);
			dto.setTitle(title);
			dto.setContent(content);

			//DAO 
			RegionDAO dao = new RegionDAO();
			int rs = dao.updateWrite(dto);

			// 5. move
			String path = request.getContextPath() + "/region/view.reg?num="+num;
			response.sendRedirect(path);
		}else if(action.equals("/deleteProc.reg")) {
			// 값 받기
			request.setCharacterEncoding("utf-8");
			String sNum = request.getParameter("num");
			int num = Integer.parseInt(sNum);

			// 2. 값 출력
			//System.out.println(num);

			// 3. DTO
			RegionDTO dto = new RegionDTO();		
			dto.setNum(num);

			// 4. DAO 
			RegionDAO dao = new RegionDAO();
			int rs = dao.deleteWrite(dto);

			// 5. move : get
			String path = request.getContextPath() + "/region/list.reg";
			response.sendRedirect(path);
		}
	}
}