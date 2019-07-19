package com.tysoft.common;

import static org.bytedeco.javacpp.opencv_highgui.imshow;
import static org.bytedeco.javacpp.opencv_highgui.waitKey;
import static org.bytedeco.javacpp.opencv_imgcodecs.imread;
import static org.bytedeco.javacpp.opencv_imgcodecs.imwrite;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import javax.swing.WindowConstants;
import org.bytedeco.javacpp.opencv_core;
import org.bytedeco.javacpp.opencv_core.Mat;
import org.bytedeco.javacpp.opencv_imgproc;
import org.bytedeco.javacpp.opencv_objdetect.CascadeClassifier;
import org.bytedeco.javacv.CanvasFrame;
import org.bytedeco.javacv.Frame;
import org.bytedeco.javacv.OpenCVFrameConverter;
import org.bytedeco.javacv.VideoInputFrameGrabber;
import org.opencv.core.Core;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfInt;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

public class FaceUtils {

	static {
		System.out.println("====我要进入加载了====");
		System.load("D:\\opencv\\build\\java\\x64\\opencv_java320.dll");
		System.out.println("====加载成功====");
	}

	public static void loadImg() {
		Mat image = imread("C:\\Users\\Administrator\\Desktop\\\\me\\Fri Jan 25 15-30-22.bmp");
		if (image.empty()) {
			System.err.println("加载图片出错，请检查图片路径！");
			return;
		} // 显示图片
		imshow("显示原始图像", image);
		//无限等待按键按下
		waitKey(0);
	}

	/**
	 * * 测试摄像头 *
	 * Title: Camera
	 * Description:
	 * InterruptedException
	 */
	public static void camera() throws Exception, InterruptedException {
		VideoInputFrameGrabber grabber = VideoInputFrameGrabber.createDefault(1);
		grabber.start();
		CanvasFrame canvasFrame = new CanvasFrame("摄像头");
		canvasFrame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
		canvasFrame.setAlwaysOnTop(true);
		while (true) {
			if (!canvasFrame.isDisplayable()) {
				grabber.stop();
				System.exit(-1);
			}
			Frame frame = grabber.grab();
			canvasFrame.showImage(frame);
			Thread.sleep(30);
		}
	}
	
	/**
	 * * 裁剪人脸 *
	 * Title: Camera
	 * Description:
	 * InterruptedException
	 */
	public static void testFace(String path) throws Exception, InterruptedException{
		Mat image = imread(path); 
        if (image.empty()) {
            System.err.println("加载图片出错，请检查图片路径！");
            return;
	}
        opencv_core.RectVector faces = new opencv_core.RectVector();
      //初始化人脸检测器
        CascadeClassifier face_cascade = new CascadeClassifier("D:\\opencv\\sources\\data\\haarcascades_cuda\\haarcascade_frontalface_alt.xml");
        //当前帧图片进行灰度+直方均衡
        Mat videoMatGray = new Mat();
        opencv_imgproc.cvtColor(image, videoMatGray, Imgproc.COLOR_BGRA2GRAY);
        opencv_imgproc.equalizeHist(videoMatGray, videoMatGray);
        //使用检测器进行检测，把结果放进集合中 
        face_cascade.detectMultiScale(videoMatGray, faces);
        //把所有人脸数据绘制到图片中
        File imagePath = new File(path);
        String dir = imagePath.getParent();
        String name = imagePath.getName().substring(0, imagePath.getName().lastIndexOf(".")); 
        for (int i = 0; i < faces.size(); i++) {
        	opencv_core.Rect face = faces.get(i);  
         Mat img_region = new Mat(image, face);
         // imshow("人脸裁剪"+i, img_region);
         imwrite(dir+File.separator+name+" face"+i+".png", img_region); 
         }
         //waitKey(0);
        }
	
	/**
	 * * 人脸识别视频识别 *
	 * Title: Camera
	 * Description:
	 * InterruptedException
	 */
	public static void detectFace() throws org.bytedeco.javacv.FrameGrabber.Exception, InterruptedException{
		//连接摄像头
		VideoInputFrameGrabber grabber = VideoInputFrameGrabber.createDefault(1);
        grabber.start();
        OpenCVFrameConverter.ToMat convertToMat = new OpenCVFrameConverter.ToMat();
        //加载检测器
        CascadeClassifier face_cascade = new CascadeClassifier("D:\\opencv\\sources\\data\\haarcascades_cuda\\haarcascade_frontalface_alt.xml");//初始化人脸检测器
        CascadeClassifier eye_cascade = new CascadeClassifier("D:\\opencv\\sources\\data\\haarcascades_cuda\\haarcascade_eye_tree_eyeglasses.xml");//初始化眼部检测器
        //定义人脸集合，矩形集合
        opencv_core.RectVector faces = new opencv_core.RectVector();
        opencv_core.RectVector eyes = new opencv_core.RectVector();
        CanvasFrame canvas = new CanvasFrame("人脸识别",1);
        //新建一个窗口 
        canvas.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        while (true) {
            if (!canvas.isVisible()) {
                break;
            }
            Frame frame = grabber.grab();
            //获取当前帧图片
            Mat mat = convertToMat.convert(frame);
            if (mat.empty())
            	continue;
            //当前帧图片进行灰度+直方均衡
            Mat videoMatGray = new Mat();
            opencv_imgproc.cvtColor(mat, videoMatGray, Imgproc.COLOR_BGRA2GRAY);
            opencv_imgproc.equalizeHist(videoMatGray, videoMatGray);
            //使用检测器进行检测，把结果放进集合中
            face_cascade.detectMultiScale(videoMatGray, faces);
            eye_cascade.detectMultiScale(videoMatGray, eyes);
            //把所有人脸数据绘制到图片中
            for (int i = 0; i < faces.size(); i++) {
            	opencv_core.Rect face = faces.get(i);
            	opencv_imgproc.rectangle(mat, face, opencv_core.Scalar.RED, 1, 8, 0);
            }
            for (int i = 0; i < eyes.size(); i++) {
            	opencv_core.Rect eye = eyes.get(i);
            	opencv_imgproc.rectangle(mat, eye, opencv_core.Scalar.GREEN, 1, 8, 0);
            }
            //把图片刷新到窗口
            canvas.showImage(convertToMat.convert(mat));
            Thread.sleep(30);//30毫秒刷新一次图像
        }
    }
	
	 public static double CmpPic(String src, String des) {
		 System.out.println("\n==========直方图比较==========");
	     //自定义阈值
		 //相关性阈值，应大于多少，越接近1表示越像，最大为1
		 double HISTCMP_CORREL_THRESHOLD = 0.7;
		 //卡方阈值，应小于多少，越接近0表示越像
		 double HISTCMP_CHISQR_THRESHOLD = 2;
		 //交叉阈值，应大于多少，数值越大表示越像
		 double HISTCMP_INTERSECT_THRESHOLD = 1.2;
		 //巴氏距离阈值，应小于多少，越接近0表示越像
		 double HISTCMP_BHATTACHARYYA_THRESHOLD = 0.3;
		 try {
			 long startTime = System.currentTimeMillis();
			 org.opencv.core.Mat mat_src = Imgcodecs.imread(src);
			 org.opencv.core.Mat mat_des = Imgcodecs.imread(des);;
			 if (mat_src.empty() || mat_des.empty()) {
				 throw new Exception("no file.");
				 }
			 org.opencv.core.Mat hsv_src = new org.opencv.core.Mat();
			 org.opencv.core.Mat hsv_des = new org.opencv.core.Mat();
			 // 转换成HSV
			 Imgproc.cvtColor(mat_src, hsv_src, Imgproc.COLOR_BGR2HSV);	
			 Imgproc.cvtColor(mat_des, hsv_des, Imgproc.COLOR_BGR2HSV);
			 List<org.opencv.core.Mat> listImg1 = new ArrayList<org.opencv.core.Mat>();
		     List<org.opencv.core.Mat> listImg2 = new ArrayList<org.opencv.core.Mat>();	
		     listImg1.add(hsv_src);
		     listImg2.add(hsv_des);
		     MatOfFloat ranges = new MatOfFloat(0, 255);
		     MatOfInt histSize = new MatOfInt(50);
		     MatOfInt channels = new MatOfInt(0);
		     org.opencv.core.Mat histImg1 = new org.opencv.core.Mat();
		     org.opencv.core.Mat histImg2 = new org.opencv.core.Mat();
		     //org.bytedeco.javacpp中的方法不太了解参数，所以直接上org.opencv中的方法，所以需要加载一下dll，System.load("D:\\soft\\openCV3\\opencv\\build\\java\\x64\\opencv_java345.dll");
		     //opencv_imgproc.calcHist(images, nimages, channels, mask, hist, dims, histSize, ranges, uniform, accumulate);
		     Imgproc.calcHist(listImg1, channels, new org.opencv.core.Mat(), histImg1, histSize, ranges);
		     Imgproc.calcHist(listImg2, channels, new org.opencv.core.Mat(), histImg2, histSize, ranges);
		     org.opencv.core.Core.normalize(histImg1, histImg1, 0d, 1d, Core.NORM_MINMAX, -1,new org.opencv.core.Mat());
		     org.opencv.core.Core.normalize(histImg2, histImg2, 0d, 1d, Core.NORM_MINMAX, -1,new org.opencv.core.Mat());
		     double result0, result1, result2, result3;
		     result0 = Imgproc.compareHist(histImg1, histImg2, Imgproc.HISTCMP_CORREL);
		     result1 = Imgproc.compareHist(histImg1, histImg2, Imgproc.HISTCMP_CHISQR);
		     result2 = Imgproc.compareHist(histImg1, histImg2, Imgproc.HISTCMP_INTERSECT);
		     result3 = Imgproc.compareHist(histImg1, histImg2, Imgproc.HISTCMP_BHATTACHARYYA);
		     System.out.println("相关性（度量越高，匹配越准确 [基准："+HISTCMP_CORREL_THRESHOLD+"]）,当前值:" + result0);
		     System.out.println("卡方（度量越低，匹配越准确 [基准："+HISTCMP_CHISQR_THRESHOLD+"]）,当前值:" + result1);
		     System.out.println("交叉核（度量越高，匹配越准确 [基准："+HISTCMP_INTERSECT_THRESHOLD+"]）,当前值:" + result2);
		     System.out.println("巴氏距离（度量越低，匹配越准确 [基准："+HISTCMP_BHATTACHARYYA_THRESHOLD+"]）,当前值:" + result3);
		     //一共四种方式，有三个满足阈值就算匹配成功	
		     int count = 0;
		     if (result0 > HISTCMP_CORREL_THRESHOLD)
		    	 count++;
		     if (result1 < HISTCMP_CHISQR_THRESHOLD)
		    	 count++;
		     if (result2 > HISTCMP_INTERSECT_THRESHOLD)
		    	 count++;
		     if (result3 < HISTCMP_BHATTACHARYYA_THRESHOLD)
		    	 count++;
		     int retVal = 0;
		     if (count >= 3) {
		    	 //这是相似的图像
		    	 retVal = 1;
		    	 }
		     long estimatedTime = System.currentTimeMillis() - startTime;
		     System.out.println("花费时间= " + estimatedTime + "ms");
		     return retVal;
		     } catch (Exception e) {
		    	 System.out.println("例外:" + e);
		    	 }	
		 return 0;  
	 }
	 
	 public static void test() {
		 String imgPath1="D:\\face\\1.jpg";
		 String imgPath2="D:\\face\\3.jpg";
		 System.out.println(FaceUtils.CmpPic(imgPath1,imgPath2));
	 }

}
