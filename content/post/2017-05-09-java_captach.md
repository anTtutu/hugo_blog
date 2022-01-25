---
title: Java高防OCR和机器人图形验证码
date: 2017-05-09T21:46:20+08:00
tags: [ "java", "captcha" ] 
description: "Java原生图形验证码"
categories: [ "java", "captcha" ]
toc: true
---   

　结合网上的图形验证码技术，不依赖第三方包纯java加工了一个比较复杂的图形验证码方案，防OCR、防机器人。  
　网上的图形验证码方案都是零星的，弄了一个随机字体、随机彩色字符、随机字体大小、随机扭曲、随机旋转等技术，能有效的防OCR、描边、深浅色等技术识别。  
　本意是想区分登录、领券、抽奖等一些场景操作的，后来一想，随机拼人品吧，于是就有了下面的工具类。

## 效果图如下：    
### 静态jpg
![](/posts/imgCode/AYhf.jpg) ![](/posts/imgCode/ni8P.jpg) ![](/posts/imgCode/2GmY.jpg)
### 动态gif
![](/posts/imgCode/grNc.gif) ![](/posts/imgCode/arLP.gif) ![](/posts/imgCode/bdPp.gif)

## 代码如下：    
如下共计有6个类，图形验证码工具类，使用方法调用，老外的Encoder、GifDecoder、GifEncoder、Quant等4个工具类

### 1、图形验证码工具类
```java
package com.test.test;    
    
import java.awt.AlphaComposite;    
import java.awt.Color;    
import java.awt.Font;    
import java.awt.Graphics;    
import java.awt.Graphics2D;    
import java.awt.RenderingHints;    
import java.awt.geom.AffineTransform;    
import java.awt.image.BufferedImage;    
import java.io.ByteArrayInputStream;    
import java.io.File;    
import java.io.FileOutputStream;    
import java.io.IOException;    
import java.io.OutputStream;    
import java.util.Arrays;    
import java.util.Random;    
    
import javax.imageio.ImageIO;

import org.apache.log4j.Logger;    
    
/**  
 * 验证码工具类：  
 * 随机字体、字体样式、字体大小（验证码图片宽度 - 8 ~ 验证码图片宽度 + 10）  
 * 彩色字符 每个字符的颜色随机，一定会不相同  
 * 随机字符 阿拉伯数字 + 小写字母 + 大写字母  
 * 3D中空自定义字体，需要单独使用，只有阿拉伯数字和大写字母  
 * gif支持动态输出
 * 2017-06-09 解决压测时自定义字符字体不停的new，内存溢出问题。因为自定义字体不会变，提成static,建议用64bit jdk，自定义自动字符串太长，32bit偶尔编译会报错字符串太长
 * @author Anttu  
 * @date 2017年5月9日 下午7:27:55  
 */    
public class RandonImgCodeUtil    
{
	  private static Logger logger = Logger.getLogger(RandomVerifyImgCodeUtil.class);
	  
    /**  
     * 随机类  
     */    
    private static Random random = new Random();    
    
    // 放到session中的key    
    public static final String RANDOMCODEKEY = "RANDOMVALIDATECODEKEY";    
    
    // 验证码来源范围，去掉了0,1,I,O,l,o几个容易混淆的字符    
    public static final String VERIFY_CODES = "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz";
    
    private static ImgFontByte imgFontByte = new ImgFontByte();
	
	private static Font baseFont;
    static
    {
        try
        {
            baseFont = Font.createFont(Font.TRUETYPE_FONT,
                    RandomVerifyImgCodeUtils.class.getClassLoader().getResourceAsStream("fonts/ActionJackson.TTF"));
        }
        catch (FontFormatException e)
        {
            logger.error("new img font font format failed. e: " + e.getMessage(), e);
        }
        catch (IOException e)
        {
            logger.error("new img font io failed. e: " + e.getMessage(), e);
        }
    }
    
    // 字体类型    
    private static String[] fontName =    
    {    
            "Algerian", "Arial", "Arial Black", "Agency FB", "Calibri", "Cambria", "Gadugi", "Georgia", "Consolas", "Comic Sans MS", "Courier New",    
            "Gill sans", "Time News Roman", "Tahoma", "Quantzite", "Verdana"    
    };    
    
    // 字体样式    
    private static int[] fontStyle =    
    {    
            Font.BOLD, Font.ITALIC, Font.ROMAN_BASELINE, Font.PLAIN, Font.BOLD + Font.ITALIC    
    };    
    
    // 颜色    
    private static Color[] colorRange =    
    {    
            Color.WHITE, Color.CYAN, Color.GRAY, Color.LIGHT_GRAY, Color.MAGENTA, Color.ORANGE, Color.PINK, Color.YELLOW, Color.GREEN, Color.BLUE,    
            Color.DARK_GRAY, Color.BLACK, Color.RED    
    };    
    
    /**  
     * 使用系统默认字符源生成验证码  
     *   
     * @param verifySize 验证码长度  
     * @return  
     */    
    public static String generateVerifyCode(int verifySize)    
    {    
        return generateVerifyCode(verifySize, VERIFY_CODES);    
    }    
    
    /**  
     * 使用指定源生成验证码  
     *   
     * @param verifySize 验证码长度  
     * @param sources 验证码字符源  
     * @return  
     */    
    private static String generateVerifyCode(int verifySize, String sources)    
    {    
        if (sources == null || sources.length() == 0)    
        {    
            sources = VERIFY_CODES;    
        }    
        int codesLen = sources.length();    
        Random rand = new Random(System.currentTimeMillis());    
        StringBuilder verifyCode = new StringBuilder(verifySize);    
        for (int i = 0; i < verifySize; i++)    
        {    
            verifyCode.append(sources.charAt(rand.nextInt(codesLen - 1)));    
        }    
    
        return verifyCode.toString();    
    }    
    
    /**  
     * 输出指定验证码图片流  
     *   
     * @param w 验证码图片的宽  
     * @param h 验证码图片的高  
     * @param os 流  
     * @param code 验证码  
     * @param type 场景类型，login：登录，  
     *            coupons：领券 登录清晰化，领券模糊化  
     *            3D: 3D中空自定义字体  
     *            GIF：普通动态GIF  
     *            GIF3D：3D动态GIF  
     *            mix2: 普通字体和3D字体混合  
     *            mixGIF: 混合动态GIF  
     * @throws IOException  
     */    
    public static void outputImage(int w, int h, OutputStream os, String code, String type) throws IOException    
    {    
        int verifySize = code.length();    
        BufferedImage image = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);    
        Random rand = new Random();    
        Graphics2D g2 = image.createGraphics();    
        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);    
        Color[] colors = new Color[5];    
        Color[] colorSpaces = colorRange;    
        float[] fractions = new float[colors.length];    
        for (int i = 0; i < colors.length; i++)    
        {    
            colors[i] = colorSpaces[rand.nextInt(colorSpaces.length)];    
            fractions[i] = rand.nextFloat();    
        }    
        Arrays.sort(fractions);    
    
        g2.setColor(Color.GRAY);// 设置边框色    
        g2.fillRect(0, 0, w, h);    
    
        Color c = getRandColor(200, 250);    
        g2.setColor(c);// 设置背景色    
        g2.fillRect(0, 2, w, h - 4);    
    
        char[] charts = code.toCharArray();    
        for (int i = 0; i < charts.length; i++)    
        {    
            g2.setColor(c);// 设置背景色    
            g2.setFont(getRandomFont(h, type));    
            g2.fillRect(0, 2, w, h - 4);    
        }    
    
        // 1.绘制干扰线    
        Random random = new Random();    
        g2.setColor(getRandColor(160, 200));// 设置线条的颜色    
        int lineNumbers = 20;    
        if (type.equals("login") || type.contains("mix") || type.contains("3D"))    
        {    
            lineNumbers = 20;    
        }    
        else if (type.equals("coupons"))    
        {    
            lineNumbers = getRandomDrawLine();    
        }    
        else    
        {    
            lineNumbers = getRandomDrawLine();    
        }    
        for (int i = 0; i < lineNumbers; i++)    
        {    
            int x = random.nextInt(w - 1);    
            int y = random.nextInt(h - 1);    
            int xl = random.nextInt(6) + 1;    
            int yl = random.nextInt(12) + 1;    
            g2.drawLine(x, y, x + xl + 40, y + yl + 20);    
        }    
    
        // 2.添加噪点    
        float yawpRate = 0.05f;    
        if (type.equals("login") || type.contains("mix") || type.contains("3D"))    
        {    
            yawpRate = 0.05f; // 噪声率    
        }    
        else if (type.equals("coupons"))    
        {    
            yawpRate = getRandomDrawPoint(); // 噪声率    
        }    
        else    
        {    
            yawpRate = getRandomDrawPoint(); // 噪声率    
        }    
        int area = (int) (yawpRate * w * h);    
        for (int i = 0; i < area; i++)    
        {    
            int x = random.nextInt(w);    
            int y = random.nextInt(h);    
            int rgb = getRandomIntColor();    
            image.setRGB(x, y, rgb);    
        }    
    
        // 3.使图片扭曲    
        shear(g2, w, h, c);    
    
        char[] chars = code.toCharArray();    
        Double rd = rand.nextDouble();    
        Boolean rb = rand.nextBoolean();    
    
        if (type.equals("login"))    
        {    
            for (int i = 0; i < verifySize; i++)    
            {    
                g2.setColor(getRandColor(100, 160));    
                g2.setFont(getRandomFont(h, type));    
    
                AffineTransform affine = new AffineTransform();    
                affine.setToRotation(Math.PI / 4 * rd * (rb ? 1 : -1), (w / verifySize) * i + (h - 4) / 2, h / 2);    
                g2.setTransform(affine);    
                g2.drawOval(random.nextInt(w), random.nextInt(h), 5 + random.nextInt(10), 5 + random.nextInt(10));    
                g2.drawChars(chars, i, 1, ((w - 10) / verifySize) * i + 5, h / 2 + (h - 4) / 2 - 10);    
            }    
    
            g2.dispose();    
            ImageIO.write(image, "jpg", os);    
        }    
        else if (type.contains("GIF") || type.contains("mixGIF"))    
        {    
            GifEncoder gifEncoder = new GifEncoder(); // gif编码类，这个利用了洋人写的编码类    
            // 生成字符    
            gifEncoder.start(os);    
            gifEncoder.setQuality(180);    
            gifEncoder.setDelay(150);    
            gifEncoder.setRepeat(0);    
    
            AlphaComposite ac3;    
            for (int i = 0; i < verifySize; i++)    
            {    
                g2.setColor(getRandColor(100, 160));    
                g2.setFont(getRandomFont(h, type));    
                for (int j = 0; j < verifySize; j++)    
                {    
                    AffineTransform affine = new AffineTransform();    
                    affine.setToRotation(Math.PI / 4 * rd * (rb ? 1 : -1), (w / verifySize) * i + (h - 4) / 2, h / 2);    
                    g2.setTransform(affine);    
                    g2.drawChars(chars, i, 1, ((w - 10) / verifySize) * i + 5, h / 2 + (h - 4) / 2 - 10);    
    
                    ac3 = AlphaComposite.getInstance(AlphaComposite.SRC_OVER, getAlpha(j, i, verifySize));    
                    g2.setComposite(ac3);    
                    g2.drawOval(random.nextInt(w), random.nextInt(h), 5 + random.nextInt(10), 5 + random.nextInt(10));    
                    gifEncoder.addFrame(image);    
                    image.flush();    
                }    
            }    
            gifEncoder.finish();    
            g2.dispose();    
        }    
        else    
        {    
            for (int i = 0; i < verifySize; i++)    
            {    
                g2.setColor(getRandColor(100, 160));    
                g2.setFont(getRandomFont(h, type));    
    
                AffineTransform affine = new AffineTransform();    
                affine.setToRotation(Math.PI / 4 * rd * (rb ? 1 : -1), (w / verifySize) * i + (h - 4) / 2, h / 2);    
                g2.setTransform(affine);    
                g2.drawOval(random.nextInt(w), random.nextInt(h), 5 + random.nextInt(10), 5 + random.nextInt(10));    
                g2.drawChars(chars, i, 1, ((w - 10) / verifySize) * i + 5, h / 2 + (h - 4) / 2 - 10);    
            }    
    
            g2.dispose();    
            ImageIO.write(image, "jpg", os);    
        }    
    }    
    
    /**  
     * 获取随机颜色  
     *   
     * @param fc  
     * @param bc  
     * @return  
     */    
    private static Color getRandColor(int fc, int bc)    
    {    
        if (fc > 255)    
        {    
            fc = 255;    
        }    
        if (bc > 255)    
        {    
            bc = 255;    
        }    
        int r = fc + random.nextInt(bc - fc);    
        int g = fc + random.nextInt(bc - fc);    
        int b = fc + random.nextInt(bc - fc);    
        return new Color(r, g, b);    
    }    
    
    private static int getRandomIntColor()    
    {    
        int[] rgb = getRandomRgb();    
        int color = 0;    
        for (int c : rgb)    
        {    
            color = color << 8;    
            color = color | c;    
        }    
        return color;    
    }    
    
    private static int[] getRandomRgb()    
    {    
        int[] rgb = new int[3];    
        for (int i = 0; i < 3; i++)    
        {    
            rgb[i] = random.nextInt(255);    
        }    
        return rgb;    
    }    
    
    /**  
     * 随机字体、随机风格、随机大小  
     *   
     * @param h 验证码图片高  
     * @return  
     */    
    private static Font getRandomFont(int h, String type)    
    {    
        // 字体    
        String name = fontName[random.nextInt(fontName.length)];    
        // 字体样式    
        int style = fontStyle[random.nextInt(fontStyle.length)];    
        // 字体大小    
        int size = getRandomFontSize(h);    
    
        if (type.equals("login"))    
        {    
            return new Font(name, style, size);    
        }    
        else if (type.equals("coupons"))    
        {    
            return new Font(name, style, size);    
        }    
        else if (type.contains("3D"))    
        {    
            return new ImgFontByte().getFont(size, style);    
        }    
        else if (type.contains("mix"))    
        {    
            int flag = random.nextInt(10);    
            if (flag > 4)    
            {    
                return new Font(name, style, size);    
            }    
            else    
            {    
                return new ImgFontByte().getFont(size, style);    
            }    
        }    
        else    
        {    
            return new Font(name, style, size);    
        }    
    }    
    
    /**  
     * 干扰线按范围获取随机数  
     *   
     * @return  
     */    
    private static int getRandomDrawLine()    
    {    
        int min = 20;    
        int max = 155;    
        Random random = new Random();    
        return random.nextInt(max) % (max - min + 1) + min;    
    }    
    
    /**  
     * 噪点数率按范围获取随机数  
     *   
     * @return  
     */    
    private static float getRandomDrawPoint()    
    {    
        float min = 0.05f;    
        float max = 0.1f;    
        return min + ((max - min) * new Random().nextFloat());    
    }    
    
    /**  
     * 获取字体大小按范围随机  
     *   
     * @param h 验证码图片高  
     * @return  
     */    
    private static int getRandomFontSize(int h)    
    {    
        int min = h - 8;    
        // int max = 46;    
        Random random = new Random();    
        return random.nextInt(11) + min;    
    }    
    
    /**  
     * 3D中空字体自定义属性类  
     *   
     * @author Anttu  
     * @date 2017年5月15日 下午3:27:52  
     */    
    static class ImgFontByte
    {
        public Font getFont(int fontSize, int fontStype)
        {
            try
            {
                Font font = baseFont;
                if (baseFont == null)
                {
                    font = Font.createFont(Font.TRUETYPE_FONT, RandomVerifyImgCodeUtils.class.getClassLoader()
                            .getResourceAsStream("fonts/ActionJackson.TTF"));
                }
                return font.deriveFont(fontStype, fontSize);
            }
            catch (Exception e)
            {
                return new Font("Arial", fontStype, fontSize);
            }
        }
    }    
    
    /**  
     * 字符和干扰线扭曲  
     *   
     * @param g 绘制图形的java工具类  
     * @param w1 验证码图片宽  
     * @param h1 验证码图片高  
     * @param color 颜色  
     */    
    private static void shear(Graphics g, int w1, int h1, Color color)    
    {    
        shearX(g, w1, h1, color);    
        shearY(g, w1, h1, color);    
    }    
    
    /**  
     * x轴扭曲  
     *   
     * @param g 绘制图形的java工具类  
     * @param w1 验证码图片宽  
     * @param h1 验证码图片高  
     * @param color 颜色  
     */    
    private static void shearX(Graphics g, int w1, int h1, Color color)    
    {    
        int period = random.nextInt(2);    
    
        boolean borderGap = true;    
        int frames = 1;    
        int phase = random.nextInt(2);    
    
        for (int i = 0; i < h1; i++)    
        {    
            double d = (double) (period >> 1) * Math.sin((double) i / (double) period + (6.2831853071795862D * (double) phase) / (double) frames);    
            g.copyArea(0, i, w1, 1, (int) d, 0);    
            if (borderGap)    
            {    
                g.setColor(color);    
                g.drawLine((int) d, i, 0, i);    
                g.drawLine((int) d + w1, i, w1, i);    
            }    
        }    
    }    
    
    /**  
     * y轴扭曲  
     *   
     * @param g 绘制图形的java工具类  
     * @param w1 验证码图片宽  
     * @param h1 验证码图片高  
     * @param color 颜色  
     */    
    private static void shearY(Graphics g, int w1, int h1, Color color)    
    {    
        int period = random.nextInt(40) + 10; // 50;    
    
        boolean borderGap = true;    
        int frames = 20;    
        int phase = 7;    
        for (int i = 0; i < w1; i++)    
        {    
            double d = (double) (period >> 1) * Math.sin((double) i / (double) period + (6.2831853071795862D * (double) phase) / (double) frames);    
            g.copyArea(i, 0, 1, h1, 0, (int) d);    
            if (borderGap)    
            {    
                g.setColor(color);    
                g.drawLine(i, (int) d, i, 0);    
                g.drawLine(i, (int) d + h1, i, h1);    
            }    
        }    
    }    
    
    /**  
     * 获取透明度,从0到1,自动计算步长  
     *   
     * @param i  
     * @param j  
     * @return float 透明度  
     */    
    private static float getAlpha(int i, int j, int verifySize)    
    {    
        int num = i + j;    
        float r = (float) 1 / verifySize, s = (verifySize + 1) * r;    
        return num > verifySize ? (num * r - s) : num * r;    
    }    
    
    /**  
     * 生成指定验证码图像文件 - 本地测试生成图片查看效果  
     *   
     * @param w 验证码图片宽  
     * @param h 验证码图片高  
     * @param outputFile 文件流  
     * @param code 随机验证码  
     * @throws IOException  
     */    
    public static void outputImage(int w, int h, File outputFile, String code) throws IOException    
    {    
        if (outputFile == null)    
        {    
            return;    
        }    
        File dir = outputFile.getParentFile();    
        if (!dir.exists())    
        {    
            dir.mkdirs();    
        }    
        try    
        {    
            outputFile.createNewFile();    
            FileOutputStream fos = new FileOutputStream(outputFile);    
            // outputImage(w, h, fos, code, "login"); //测试登录，噪点和干扰线为0.05f和20    
            // outputImage(w, h, fos, code, "coupons"); //测试领券，噪点和干扰线为范围随机值0.05f ~ 0.1f和20 ~ 155    
            // outputImage(w, h, fos, code, "3D"); //测试领券，噪点和干扰线为范围随机值0.05f ~ 0.1f和20 ~ 155    
            // outputImage(w, h, fos, code, "GIF"); //测试领券，噪点和干扰线为范围随机值0.05f ~ 0.1f和20 ~ 155    
            // outputImage(w, h, fos, code, "GIF3D"); //测试领券，噪点和干扰线为范围随机值0.05f ~ 0.1f和20 ~ 155    
            // outputImage(w, h, fos, code, "mix2"); //测试领券，噪点和干扰线为范围随机值0.05f ~ 0.1f和20 ~ 155    
            outputImage(w, h, fos, code, "mixGIF"); // 测试领券，噪点和干扰线为范围随机值0.05f ~ 0.1f和20 ~ 155    
            fos.close();    
        }    
        catch (IOException e)    
        {    
            throw e;    
        }    
    }    
    
    /**  
     * 本地测试类，可以生成样例验证码图片供观看效果  
     *   
     * @param args  
     * @throws IOException  
     */    
    public static void main(String[] args) throws IOException    
    {    
        File dir = new File("E:/logtest/verifies8");    
        int w = 120, h = 48;    
        for (int i = 0; i < 150; i++)    
        {    
            String verifyCode = generateVerifyCode(4);    
            File file = new File(dir, verifyCode + ".gif");    
            outputImage(w, h, file, verifyCode);    
        }    
    }    
    
}
```

### 2、调用示例
```java
public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException  
{  
    response.setContentType("image/jpeg");  
    // 设置相应类型,告诉浏览器输出的内容为图片  
    response.setHeader("Pragma", "No-cache");  
    // 设置响应头信息，告诉浏览器不要缓存此内容  
    response.setHeader("Cache-Control", "no-cache");  
    response.setDateHeader("Expire", 0);  
      
    try  
    {  
        // 生成随机验证码  
        int charSize = 4;  
        String verifyCode = RandomVerifyImgCodeUtil.generateVerifyCode(charSize);  
          
        if (StringUtils.isNotBlank(verifyCode))  
        {  
            RedisUtil redisUtil = SpringContextUtils.getBean(RedisUtil.class);  
              
            String key = request.getSession().getId() + "_" + RANDOMCODEKEY;  
            redisUtil.set(key, verifyCode.toString());  
            /** 设置sesionTooken,90s后失效 **/  
            redisUtil.expired(key, 90);  
              
            // 再次存cookie备份  
            CookieUtil.addCookie(request, response, RANDOMCODEKEY, verifyCode, 300);  
        }  
          
        // 生成图片规格w宽 h高   
        int w = 100, h = 40;  
        int type = new Random().nextInt(7);   
        switch(type)  
        {  
            case 0:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "login"); 
                break;  
             case 1:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "GIF");
                break;  
            case 2:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "3D");  
                break;  
            case 3:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "GIF3D");
                break;  
            case 4:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "mix2");  
                break;  
            case 5:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "mixGIF");
                break;  
            case 6:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "coupons");  
                break;  
            default:  
                RandomVerifyImgCodeUtil.outputImage(w, h, response.getOutputStream(), verifyCode, "mixGIF");
                break;  
        }             
    }  
    catch (Exception e)  
    {  
        logger.error(e.getMessage(), e);  
    }  
}    
```

### 3、用到的老外的工具类：共计4个，如果只是生成的话用不了这么多
### I、Encoder
```java  
package com.test.test;    
    
import java.io.IOException;    
import java.io.OutputStream;    
    
/**  
 * @author: wuhongjun  
 * @version:1.0  
 */    
public class Encoder    
{    
    private static final int EOF = -1;    
    
    private int imgW, imgH;    
    private byte[] pixAry;    
    private int initCodeSize;    
    private int remaining;    
    private int curPixel;    
    
    // GIFCOMPR.C - GIF Image compression routines    
    //    
    // Lempel-Ziv compression based on 'compress'. GIF modifications by    
    // David Rowley (mgardi@watdcsu.waterloo.edu)    
    
    // General DEFINEs    
    
    static final int BITS = 12;    
    
    static final int HSIZE = 5003; // 80% occupancy    
    
    // GIF Image compression - modified 'compress'    
    //    
    // Based on: compress.c - File compression ala IEEE Computer, June 1984.    
    //    
    // By Authors: Spencer W. Thomas (decvax!harpo!utah-cs!utah-gr!thomas)    
    // Jim McKie (decvax!mcvax!jim)    
    // Steve Davies (decvax!vax135!petsd!peora!srd)    
    // Ken Turkowski (decvax!decwrl!turtlevax!ken)    
    // James A. Woods (decvax!ihnp4!ames!jaw)    
    // Joe Orost (decvax!vax135!petsd!joe)    
    
    int n_bits; // number of bits/code    
    int maxbits = BITS; // user settable max # bits/code    
    int maxcode; // maximum code, given n_bits    
    int maxmaxcode = 1 << BITS; // should NEVER generate this code    
    
    int[] htab = new int[HSIZE];    
    int[] codetab = new int[HSIZE];    
    
    int hsize = HSIZE; // for dynamic table sizing    
    
    int free_ent = 0; // first unused entry    
    
    // block compression parameters -- after all codes are used up,    
    // and compression rate changes, start over.    
    boolean clear_flg = false;    
    
    // Algorithm: use open addressing double hashing (no chaining) on the    
    // prefix code / next character combination. We do a variant of Knuth's    
    // algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime    
    // secondary probe. Here, the modular division first probe is gives way    
    // to a faster exclusive-or manipulation. Also do block compression with    
    // an adaptive reset, whereby the code table is cleared when the compression    
    // ratio decreases, but after the table fills. The variable-length output    
    // codes are re-sized at this point, and a special CLEAR code is generated    
    // for the decompressor. Late addition: construct the table according to    
    // file size for noticeable speed improvement on small files. Please direct    
    // questions about this implementation to ames!jaw.    
    
    int g_init_bits;    
    
    int ClearCode;    
    int EOFCode;    
    
    // output    
    //    
    // Output the given code.    
    // Inputs:    
    // code: A n_bits-bit integer. If == -1, then EOF. This assumes    
    // that n_bits =< wordsize - 1.    
    // Outputs:    
    // Outputs code to the file.    
    // Assumptions:    
    // Chars are 8 bits long.    
    // Algorithm:    
    // Maintain a BITS character long buffer (so that 8 codes will    
    // fit in it exactly). Use the VAX insv instruction to insert each    
    // code in turn. When the buffer fills up empty it and start over.    
    
    int cur_accum = 0;    
    int cur_bits = 0;    
    
    int masks[] =    
    {    
            0x0000, 0x0001, 0x0003, 0x0007, 0x000F, 0x001F, 0x003F, 0x007F, 0x00FF, 0x01FF, 0x03FF, 0x07FF, 0x0FFF, 0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF    
    };    
    
    // Number of characters so far in this 'packet'    
    int a_count;    
    
    // Define the storage for the packet accumulator    
    byte[] accum = new byte[256];    
    
    // ----------------------------------------------------------------------------    
    Encoder(int width, int height, byte[] pixels, int color_depth)    
    {    
        imgW = width;    
        imgH = height;    
        pixAry = pixels;    
        initCodeSize = Math.max(2, color_depth);    
    }    
    
    // Add a character to the end of the current packet, and if it is 254    
    // characters, flush the packet to disk.    
    void char_out(byte c, OutputStream outs) throws IOException    
    {    
        accum[a_count++] = c;    
        if (a_count >= 254)    
            flush_char(outs);    
    }    
    
    // Clear out the hash table    
    
    // table clear for block compress    
    void cl_block(OutputStream outs) throws IOException    
    {    
        cl_hash(hsize);    
        free_ent = ClearCode + 2;    
        clear_flg = true;    
    
        output(ClearCode, outs);    
    }    
    
    // reset code table    
    void cl_hash(int hsize)    
    {    
        for (int i = 0; i < hsize; ++i)    
            htab[i] = -1;    
    }    
    
    void compress(int init_bits, OutputStream outs) throws IOException    
    {    
        int fcode;    
        int i /* = 0 */;    
        int c;    
        int ent;    
        int disp;    
        int hsize_reg;    
        int hshift;    
    
        // Set up the globals: g_init_bits - initial number of bits    
        g_init_bits = init_bits;    
    
        // Set up the necessary values    
        clear_flg = false;    
        n_bits = g_init_bits;    
        maxcode = MAXCODE(n_bits);    
    
        ClearCode = 1 << (init_bits - 1);    
        EOFCode = ClearCode + 1;    
        free_ent = ClearCode + 2;    
    
        a_count = 0; // clear packet    
    
        ent = nextPixel();    
    
        hshift = 0;    
        for (fcode = hsize; fcode < 65536; fcode *= 2)    
            ++hshift;    
        hshift = 8 - hshift; // set hash code range bound    
    
        hsize_reg = hsize;    
        cl_hash(hsize_reg); // clear hash table    
    
        output(ClearCode, outs);    
    
        outer_loop: while ((c = nextPixel()) != EOF)    
        {    
            fcode = (c << maxbits) + ent;    
            i = (c << hshift) ^ ent; // xor hashing    
    
            if (htab[i] == fcode)    
            {    
                ent = codetab[i];    
                continue;    
            }    
            else if (htab[i] >= 0) // non-empty slot    
            {    
                disp = hsize_reg - i; // secondary hash (after G. Knott)    
                if (i == 0)    
                    disp = 1;    
                do    
                {    
                    if ((i -= disp) < 0)    
                        i += hsize_reg;    
    
                    if (htab[i] == fcode)    
                    {    
                        ent = codetab[i];    
                        continue outer_loop;    
                    }    
                }    
                while (htab[i] >= 0);    
            }    
            output(ent, outs);    
            ent = c;    
            if (free_ent < maxmaxcode)    
            {    
                codetab[i] = free_ent++; // code -> hashtable    
                htab[i] = fcode;    
            }    
            else    
                cl_block(outs);    
        }    
        // Put out the final code.    
        output(ent, outs);    
        output(EOFCode, outs);    
    }    
    
    // ----------------------------------------------------------------------------    
    void encode(OutputStream os) throws IOException    
    {    
        os.write(initCodeSize); // write "initial code size" byte    
    
        remaining = imgW * imgH; // reset navigation variables    
        curPixel = 0;    
    
        compress(initCodeSize + 1, os); // compress and write the pixel data    
    
        os.write(0); // write block terminator    
    }    
    
    // Flush the packet to disk, and reset the accumulator    
    void flush_char(OutputStream outs) throws IOException    
    {    
        if (a_count > 0)    
        {    
            outs.write(a_count);    
            outs.write(accum, 0, a_count);    
            a_count = 0;    
        }    
    }    
    
    final int MAXCODE(int n_bits)    
    {    
        return (1 << n_bits) - 1;    
    }    
    
    // ----------------------------------------------------------------------------    
    // Return the next pixel from the image    
    // ----------------------------------------------------------------------------    
    private int nextPixel()    
    {    
        if (remaining == 0)    
            return EOF;    
    
        --remaining;    
    
        byte pix = pixAry[curPixel++];    
    
        return pix & 0xff;    
    }    
    
    void output(int code, OutputStream outs) throws IOException    
    {    
        cur_accum &= masks[cur_bits];    
    
        if (cur_bits > 0)    
            cur_accum |= (code << cur_bits);    
        else    
            cur_accum = code;    
    
        cur_bits += n_bits;    
    
        while (cur_bits >= 8)    
        {    
            char_out((byte) (cur_accum & 0xff), outs);    
            cur_accum >>= 8;    
            cur_bits -= 8;    
        }    
    
        // If the next entry is going to be too big for the code size,    
        // then increase it, if possible.    
        if (free_ent > maxcode || clear_flg)    
        {    
            if (clear_flg)    
            {    
                maxcode = MAXCODE(n_bits = g_init_bits);    
                clear_flg = false;    
            }    
            else    
            {    
                ++n_bits;    
                if (n_bits == maxbits)    
                    maxcode = maxmaxcode;    
                else    
                    maxcode = MAXCODE(n_bits);    
            }    
        }    
    
        if (code == EOFCode)    
        {    
            // At EOF, write the rest of the buffer.    
            while (cur_bits > 0)    
            {    
                char_out((byte) (cur_accum & 0xff), outs);    
                cur_accum >>= 8;    
                cur_bits -= 8;    
            }    
    
            flush_char(outs);    
        }    
    }    
}  
```

### II、GifDecoder  
```java
package com.test.test;  
    
import java.awt.*;    
import java.awt.image.BufferedImage;    
import java.awt.image.DataBufferInt;    
import java.io.BufferedInputStream;    
import java.io.FileInputStream;    
import java.io.IOException;    
import java.io.InputStream;    
import java.net.URL;    
import java.util.ArrayList;    
    
/**  
 * <p>  
 * </p>  
 *  
 * @author: wuhongjun  
 * @version:1.0  
 */    
public class GifDecoder    
{    
    /**  
     * File read status: No errors.  
     */    
    public static final int STATUS_OK = 0;    
    
    /**  
     * File read status: Error decoding file (may be partially decoded)  
     */    
    public static final int STATUS_FORMAT_ERROR = 1;    
    
    /**  
     * File read status: Unable to open source.  
     */    
    public static final int STATUS_OPEN_ERROR = 2;    
    
    protected BufferedInputStream in;    
    protected int status;    
    
    protected int width; // full image width    
    protected int height; // full image height    
    protected boolean gctFlag; // global color table used    
    protected int gctSize; // size of global color table    
    protected int loopCount = 1; // iterations; 0 = repeat forever    
    
    protected int[] gct; // global color table    
    protected int[] lct; // local color table    
    protected int[] act; // active color table    
    
    protected int bgIndex; // background color index    
    protected int bgColor; // background color    
    protected int lastBgColor; // previous bg color    
    protected int pixelAspect; // pixel aspect ratio    
    
    protected boolean lctFlag; // local color table flag    
    protected boolean interlace; // interlace flag    
    protected int lctSize; // local color table size    
    
    protected int ix, iy, iw, ih; // current image rectangle    
    protected Rectangle lastRect; // last image rect    
    protected BufferedImage image; // current frame    
    protected BufferedImage lastImage; // previous frame    
    
    protected byte[] block = new byte[256]; // current data block    
    protected int blockSize = 0; // block size    
    
    // last graphic control extension info    
    protected int dispose = 0;    
    // 0=no action; 1=leave in place; 2=restore to bg; 3=restore to prev    
    protected int lastDispose = 0;    
    protected boolean transparency = false; // use transparent color    
    protected int delay = 0; // delay in milliseconds    
    protected int transIndex; // transparent color index    
    
    protected static final int MaxStackSize = 4096;    
    // max decoder pixel stack size    
    
    // LZW decoder working arrays    
    protected short[] prefix;    
    protected byte[] suffix;    
    protected byte[] pixelStack;    
    protected byte[] pixels;    
    
    protected ArrayList<GifFrame> frames; // frames read from current file    
    protected int frameCount;    
    
    static class GifFrame    
    {    
        public GifFrame(BufferedImage im, int del)    
        {    
            image = im;    
            delay = del;    
        }    
    
        public BufferedImage image;    
        public int delay;    
    }    
    
    /**  
     * Gets display duration for specified frame.  
     *  
     * @param n  
     *            int index of frame  
     * @return delay in milliseconds  
     */    
    public int getDelay(int n)    
    {    
        //    
        delay = -1;    
        if ((n >= 0) && (n < frameCount))    
        {    
            delay = (frames.get(n)).delay;    
        }    
        return delay;    
    }    
    
    /**  
     * Gets the number of frames read from file.  
     *   
     * @return frame count  
     */    
    public int getFrameCount()    
    {    
        return frameCount;    
    }    
    
    /**  
     * Gets the first (or only) image read.  
     *  
     * @return BufferedImage containing first frame, or null if none.  
     */    
    public BufferedImage getImage()    
    {    
        return getFrame(0);    
    }    
    
    /**  
     * Gets the "Netscape" iteration count, if any.  
     * A count of 0 means repeat indefinitiely.  
     *  
     * @return iteration count if one was specified, else 1.  
     */    
    public int getLoopCount()    
    {    
        return loopCount;    
    }    
    
    /**  
     * Creates new frame image from current data (and previous  
     * frames as specified by their disposition codes).  
     */    
    protected void setPixels()    
    {    
        // expose destination image's pixels as int array    
        int[] dest = ((DataBufferInt) image.getRaster().getDataBuffer()).getData();    
    
        // fill in starting image contents based on last image's dispose code    
        if (lastDispose > 0)    
        {    
            if (lastDispose == 3)    
            {    
                // use image before last    
                int n = frameCount - 2;    
                if (n > 0)    
                {    
                    lastImage = getFrame(n - 1);    
                }    
                else    
                {    
                    lastImage = null;    
                }    
            }    
    
            if (lastImage != null)    
            {    
                int[] prev = ((DataBufferInt) lastImage.getRaster().getDataBuffer()).getData();    
                System.arraycopy(prev, 0, dest, 0, width * height);    
                // copy pixels    
    
                if (lastDispose == 2)    
                {    
                    // fill last image rect area with background color    
                    Graphics2D g = image.createGraphics();    
                    Color c = null;    
                    if (transparency)    
                    {    
                        c = new Color(0, 0, 0, 0); // assume background is transparent    
                    }    
                    else    
                    {    
                        c = new Color(lastBgColor); // use given background color    
                    }    
                    g.setColor(c);    
                    g.setComposite(AlphaComposite.Src); // replace area    
                    g.fill(lastRect);    
                    g.dispose();    
                }    
            }    
        }    
    
        // copy each source line to the appropriate place in the destination    
        int pass = 1;    
        int inc = 8;    
        int iline = 0;    
        for (int i = 0; i < ih; i++)    
        {    
            int line = i;    
            if (interlace)    
            {    
                if (iline >= ih)    
                {    
                    pass++;    
                    switch (pass)    
                    {    
                    case 2:    
                        iline = 4;    
                        break;    
                    case 3:    
                        iline = 2;    
                        inc = 4;    
                        break;    
                    case 4:    
                        iline = 1;    
                        inc = 2;    
                    }    
                }    
                line = iline;    
                iline += inc;    
            }    
            line += iy;    
            if (line < height)    
            {    
                int k = line * width;    
                int dx = k + ix; // start of line in dest    
                int dlim = dx + iw; // end of dest line    
                if ((k + width) < dlim)    
                {    
                    dlim = k + width; // past dest edge    
                }    
                int sx = i * iw; // start of line in source    
                while (dx < dlim)    
                {    
                    // map color and insert in destination    
                    int index = ((int) pixels[sx++]) & 0xff;    
                    int c = act[index];    
                    if (c != 0)    
                    {    
                        dest[dx] = c;    
                    }    
                    dx++;    
                }    
            }    
        }    
    }    
    
    /**  
     * Gets the image contents of frame n.  
     *  
     * @return BufferedImage representation of frame, or null if n is invalid.  
     */    
    public BufferedImage getFrame(int n)    
    {    
        BufferedImage im = null;    
        if ((n >= 0) && (n < frameCount))    
        {    
            im = (frames.get(n)).image;    
        }    
        return im;    
    }    
    
    /**  
     * Gets image size.  
     *  
     * @return GIF image dimensions  
     */    
    public Dimension getFrameSize()    
    {    
        return new Dimension(width, height);    
    }    
    
    /**  
     * Reads GIF image from stream  
     *  
     * @param is  
     *            BufferedInputStream containing GIF file.  
     * @return read status code (0 = no errors)  
     */    
    public int read(BufferedInputStream is)    
    {    
        init();    
        try    
        {    
            if (is != null)    
            {    
                in = is;    
                readHeader();    
                if (!err())    
                {    
                    readContents();    
                    if (frameCount < 0)    
                    {    
                        status = STATUS_FORMAT_ERROR;    
                    }    
                }    
            }    
            else    
            {    
                status = STATUS_OPEN_ERROR;    
            }    
        }    
        finally    
        {    
            if (null != is)    
            {    
                try    
                {    
                    is.close();    
                }    
                catch (IOException e)    
                {    
                    e.printStackTrace();    
                }    
            }    
        }    
        return status;    
    }    
    
    /**  
     * Reads GIF image from stream  
     *  
     * @param is  
     *            InputStream containing GIF file.  
     * @return read status code (0 = no errors)  
     */    
    public int read(InputStream is)    
    {    
        init();    
        try    
        {    
            if (is != null)    
            {    
                if (!(is instanceof BufferedInputStream))    
                    is = new BufferedInputStream(is);    
                in = (BufferedInputStream) is;    
                readHeader();    
                if (!err())    
                {    
                    readContents();    
                    if (frameCount < 0)    
                    {    
                        status = STATUS_FORMAT_ERROR;    
                    }    
                }    
            }    
            else    
            {    
                status = STATUS_OPEN_ERROR;    
            }    
        }    
        finally    
        {    
            if (null != is)    
            {    
                try    
                {    
                    is.close();    
                }    
                catch (IOException e)    
                {    
                    e.printStackTrace();    
                }    
            }    
        }    
        return status;    
    }    
    
    /**  
     * Reads GIF file from specified file/URL source  
     * (URL assumed if name contains ":/" or "file:")  
     *  
     * @param name  
     *            String containing source  
     * @return read status code (0 = no errors)  
     */    
    public int read(String name)    
    {    
        status = STATUS_OK;    
        try    
        {    
            name = name.trim().toLowerCase();    
            if ((name.contains("file:")) || (name.indexOf(":/") > 0))    
            {    
                URL url = new URL(name);    
                in = new BufferedInputStream(url.openStream());    
            }    
            else    
            {    
                in = new BufferedInputStream(new FileInputStream(name));    
            }    
            status = read(in);    
        }    
        catch (IOException e)    
        {    
            status = STATUS_OPEN_ERROR;    
        }    
    
        return status;    
    }    
    
    /**  
     * Decodes LZW image data into pixel array.  
     * Adapted from John Cristy's ImageMagick.  
     */    
    protected void decodeImageData()    
    {    
        int NullCode = -1;    
        int npix = iw * ih;    
        int available, clear, code_mask, code_size, end_of_information, in_code, old_code, bits, code, count, i, datum, data_size, first, top, bi, pi;    
    
        if ((pixels == null) || (pixels.length < npix))    
        {    
            pixels = new byte[npix]; // allocate new pixel array    
        }    
        if (prefix == null)    
            prefix = new short[MaxStackSize];    
        if (suffix == null)    
            suffix = new byte[MaxStackSize];    
        if (pixelStack == null)    
            pixelStack = new byte[MaxStackSize + 1];    
    
        // Initialize GIF data stream decoder.    
    
        data_size = read();    
        clear = 1 << data_size;    
        end_of_information = clear + 1;    
        available = clear + 2;    
        old_code = NullCode;    
        code_size = data_size + 1;    
        code_mask = (1 << code_size) - 1;    
        for (code = 0; code < clear; code++)    
        {    
            prefix[code] = 0;    
            suffix[code] = (byte) code;    
        }    
    
        // Decode GIF pixel stream.    
    
        datum = bits = count = first = top = pi = bi = 0;    
    
        for (i = 0; i < npix;)    
        {    
            if (top == 0)    
            {    
                if (bits < code_size)    
                {    
                    // Load bytes until there are enough bits for a code.    
                    if (count == 0)    
                    {    
                        // Read a new data block.    
                        count = readBlock();    
                        if (count <= 0)    
                            break;    
                        bi = 0;    
                    }    
                    datum += (((int) block[bi]) & 0xff) << bits;    
                    bits += 8;    
                    bi++;    
                    count--;    
                    continue;    
                }    
    
                // Get the next code.    
    
                code = datum & code_mask;    
                datum >>= code_size;    
                bits -= code_size;    
    
                // Interpret the code    
    
                if ((code > available) || (code == end_of_information))    
                    break;    
                if (code == clear)    
                {    
                    // Reset decoder.    
                    code_size = data_size + 1;    
                    code_mask = (1 << code_size) - 1;    
                    available = clear + 2;    
                    old_code = NullCode;    
                    continue;    
                }    
                if (old_code == NullCode)    
                {    
                    pixelStack[top++] = suffix[code];    
                    old_code = code;    
                    first = code;    
                    continue;    
                }    
                in_code = code;    
                if (code == available)    
                {    
                    pixelStack[top++] = (byte) first;    
                    code = old_code;    
                }    
                while (code > clear)    
                {    
                    pixelStack[top++] = suffix[code];    
                    code = prefix[code];    
                }    
                first = ((int) suffix[code]) & 0xff;    
    
                // Add a new string to the string table,    
    
                if (available >= MaxStackSize)    
                    break;    
                pixelStack[top++] = (byte) first;    
                prefix[available] = (short) old_code;    
                suffix[available] = (byte) first;    
                available++;    
                if (((available & code_mask) == 0) && (available < MaxStackSize))    
                {    
                    code_size++;    
                    code_mask += available;    
                }    
                old_code = in_code;    
            }    
    
            // Pop a pixel off the pixel stack.    
    
            top--;    
            pixels[pi++] = pixelStack[top];    
            i++;    
        }    
    
        for (i = pi; i < npix; i++)    
        {    
            pixels[i] = 0; // clear missing pixels    
        }    
    
    }    
    
    /**  
     * Returns true if an error was encountered during reading/decoding  
     */    
    protected boolean err()    
    {    
        return status != STATUS_OK;    
    }    
    
    /**  
     * Initializes or re-initializes reader  
     */    
    protected void init()    
    {    
        status = STATUS_OK;    
        frameCount = 0;    
        frames = new ArrayList<GifFrame>();    
        gct = null;    
        lct = null;    
    }    
    
    /**  
     * Reads a single byte from the input stream.  
     */    
    protected int read()    
    {    
        int curByte = 0;    
        try    
        {    
            curByte = in.read();    
        }    
        catch (IOException e)    
        {    
            status = STATUS_FORMAT_ERROR;    
        }    
        return curByte;    
    }    
    
    /**  
     * Reads next variable length block from input.  
     *  
     * @return number of bytes stored in "buffer"  
     */    
    protected int readBlock()    
    {    
        blockSize = read();    
        int n = 0;    
        if (blockSize > 0)    
        {    
            try    
            {    
                int count = 0;    
                while (n < blockSize)    
                {    
                    count = in.read(block, n, blockSize - n);    
                    if (count == -1)    
                        break;    
                    n += count;    
                }    
            }    
            catch (IOException ignored)    
            {    
            }    
    
            if (n < blockSize)    
            {    
                status = STATUS_FORMAT_ERROR;    
            }    
        }    
        return n;    
    }    
    
    /**  
     * Reads color table as 256 RGB integer values  
     *  
     * @param ncolors  
     *            int number of colors to read  
     * @return int array containing 256 colors (packed ARGB with full alpha)  
     */    
    protected int[] readColorTable(int ncolors)    
    {    
        int nbytes = 3 * ncolors;    
        int[] tab = null;    
        byte[] c = new byte[nbytes];    
        int n = 0;    
        try    
        {    
            n = in.read(c);    
        }    
        catch (IOException ignored)    
        {    
        }    
        if (n < nbytes)    
        {    
            status = STATUS_FORMAT_ERROR;    
        }    
        else    
        {    
            tab = new int[256]; // max size to avoid bounds checks    
            int i = 0;    
            int j = 0;    
            while (i < ncolors)    
            {    
                int r = ((int) c[j++]) & 0xff;    
                int g = ((int) c[j++]) & 0xff;    
                int b = ((int) c[j++]) & 0xff;    
                tab[i++] = 0xff000000 | (r << 16) | (g << 8) | b;    
            }    
        }    
        return tab;    
    }    
    
    /**  
     * Main file parser. Reads GIF content blocks.  
     */    
    protected void readContents()    
    {    
        // read GIF file content blocks    
        boolean done = false;    
        while (!(done || err()))    
        {    
            int code = read();    
            switch (code)    
            {    
    
            case 0x2C: // image separator    
                readImage();    
                break;    
    
            case 0x21: // extension    
                code = read();    
                switch (code)    
                {    
                case 0xf9: // graphics control extension    
                    readGraphicControlExt();    
                    break;    
    
                case 0xff: // application extension    
                    readBlock();    
                    String app = "";    
                    for (int i = 0; i < 11; i++)    
                    {    
                        app += (char) block[i];    
                    }    
                    if (app.equals("NETSCAPE2.0"))    
                    {    
                        readNetscapeExt();    
                    }    
                    else    
                        skip(); // don't care    
                    break;    
    
                default: // uninteresting extension    
                    skip();    
                }    
                break;    
    
            case 0x3b: // terminator    
                done = true;    
                break;    
    
            case 0x00: // bad byte, but keep going and see what happens    
                break;    
    
            default:    
                status = STATUS_FORMAT_ERROR;    
            }    
        }    
    }    
    
    /**  
     * Reads Graphics Control Extension values  
     */    
    protected void readGraphicControlExt()    
    {    
        read(); // block size    
        int packed = read(); // packed fields    
        dispose = (packed & 0x1c) >> 2; // disposal method    
        if (dispose == 0)    
        {    
            dispose = 1; // elect to keep old image if discretionary    
        }    
        transparency = (packed & 1) != 0;    
        delay = readShort() * 10; // delay in milliseconds    
        transIndex = read(); // transparent color index    
        read(); // block terminator    
    }    
    
    /**  
     * Reads GIF file header information.  
     */    
    protected void readHeader()    
    {    
        String id = "";    
        for (int i = 0; i < 6; i++)    
        {    
            id += (char) read();    
        }    
        if (!id.startsWith("GIF"))    
        {    
            status = STATUS_FORMAT_ERROR;    
            return;    
        }    
    
        readLSD();    
        if (gctFlag && !err())    
        {    
            gct = readColorTable(gctSize);    
            bgColor = gct[bgIndex];    
        }    
    }    
    
    /**  
     * Reads next frame image  
     */    
    protected void readImage()    
    {    
        ix = readShort(); // (sub)image position & size    
        iy = readShort();    
        iw = readShort();    
        ih = readShort();    
    
        int packed = read();    
        lctFlag = (packed & 0x80) != 0; // 1 - local color table flag    
        interlace = (packed & 0x40) != 0; // 2 - interlace flag    
        // 3 - sort flag    
        // 4-5 - reserved    
        lctSize = 2 << (packed & 7); // 6-8 - local color table size    
    
        if (lctFlag)    
        {    
            lct = readColorTable(lctSize); // read table    
            act = lct; // make local table active    
        }    
        else    
        {    
            act = gct; // make global table active    
            if (bgIndex == transIndex)    
                bgColor = 0;    
        }    
        int save = 0;    
        if (transparency)    
        {    
            save = act[transIndex];    
            act[transIndex] = 0; // set transparent color if specified    
        }    
    
        if (act == null)    
        {    
            status = STATUS_FORMAT_ERROR; // no color table defined    
        }    
    
        if (err())    
            return;    
    
        decodeImageData(); // decode pixel data    
        skip();    
    
        if (err())    
            return;    
    
        frameCount++;    
    
        // create new image to receive frame data    
        image = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB_PRE);    
    
        setPixels(); // transfer pixel data to image    
    
        frames.add(new GifFrame(image, delay)); // add image to frame list    
    
        if (transparency)    
        {    
            act[transIndex] = save;    
        }    
        resetFrame();    
    
    }    
    
    /**  
     * Reads Logical Screen Descriptor  
     */    
    protected void readLSD()    
    {    
    
        // logical screen size    
        width = readShort();    
        height = readShort();    
    
        // packed fields    
        int packed = read();    
        gctFlag = (packed & 0x80) != 0; // 1 : global color table flag    
        // 2-4 : color resolution    
        // 5 : gct sort flag    
        gctSize = 2 << (packed & 7); // 6-8 : gct size    
    
        bgIndex = read(); // background color index    
        pixelAspect = read(); // pixel aspect ratio    
    }    
    
    /**  
     * Reads Netscape extenstion to obtain iteration count  
     */    
    protected void readNetscapeExt()    
    {    
        do    
        {    
            readBlock();    
            if (block[0] == 1)    
            {    
                // loop count sub-block    
                int b1 = ((int) block[1]) & 0xff;    
                int b2 = ((int) block[2]) & 0xff;    
                loopCount = (b2 << 8) | b1;    
            }    
        }    
        while ((blockSize > 0) && !err());    
    }    
    
    /**  
     * Reads next 16-bit value, LSB first  
     */    
    protected int readShort()    
    {    
        // read 16-bit value, LSB first    
        return read() | (read() << 8);    
    }    
    
    /**  
     * Resets frame state for reading next image.  
     */    
    protected void resetFrame()    
    {    
        lastDispose = dispose;    
        lastRect = new Rectangle(ix, iy, iw, ih);    
        lastImage = image;    
        lastBgColor = bgColor;    
        int dispose = 0;    
        boolean transparency = false;    
        int delay = 0;    
        lct = null;    
    }    
    
    /**  
     * Skips variable length blocks up to and including  
     * next zero length block.  
     */    
    protected void skip()    
    {    
        do    
        {    
            readBlock();    
        }    
        while ((blockSize > 0) && !err());    
    }    
}  
``` 
 
### III、GifEncoder 
```java
package com.test.test;    
    
import java.awt.*;    
import java.awt.image.BufferedImage;    
import java.awt.image.DataBufferByte;    
import java.io.BufferedOutputStream;    
import java.io.ByteArrayOutputStream;    
import java.io.FileOutputStream;    
import java.io.IOException;    
import java.io.OutputStream;    
    
/**  
 * Class AnimatedGifEncoder - Encodes a GIF file consisting of one or  
 * more frames.  
 *   
 * <pre>  
 * Example:  
 *    AnimatedGifEncoder e = new AnimatedGifEncoder();  
 *    e.start(outputFileName);  
 *    e.setDelay(1000);   // 1 frame per sec  
 *    e.addFrame(image1);  
 *    e.addFrame(image2);  
 *    e.finish();  
 * </pre>  
 *   
 * No copyright asserted on the source code of this class. May be used  
 * for any purpose, however, refer to the Unisys LZW patent for restrictions  
 * on use of the associated Encoder class. Please forward any corrections  
 * to questions at fmsware.com.  
 *  
 * @author wuhongjun  
 * @version 1.03 November 2003  
 */    
public class GifEncoder    
{    
    protected int width; // image size    
    protected int height;    
    protected Color transparent = null; // transparent color if given    
    protected int transIndex; // transparent index in color table    
    protected int repeat = -1; // no repeat    
    protected int delay = 0; // frame delay (hundredths)    
    protected boolean started = false; // ready to output frames    
    protected OutputStream out;    
    protected BufferedImage image; // current frame    
    protected byte[] pixels; // BGR byte array from frame    
    protected byte[] indexedPixels; // converted frame indexed to palette    
    protected int colorDepth; // number of bit planes    
    protected byte[] colorTab; // RGB palette    
    protected boolean[] usedEntry = new boolean[256]; // active palette entries    
    protected int palSize = 7; // color table size (bits-1)    
    protected int dispose = -1; // disposal code (-1 = use default)    
    protected boolean closeStream = false; // close stream when finished    
    protected boolean firstFrame = true;    
    protected boolean sizeSet = false; // if false, get size from first frame    
    protected int sample = 10; // default sample interval for quantizer    
    
    /**  
     * Sets the delay time between each frame, or changes it  
     * for subsequent frames (applies to last frame added).  
     *  
     * @param ms  
     *            int delay time in milliseconds  
     */    
    public void setDelay(int ms)    
    {    
        delay = Math.round(ms / 10.0f);    
    }    
    
    /**  
     * Sets the GIF frame disposal code for the last added frame  
     * and any subsequent frames. Default is 0 if no transparent  
     * color has been set, otherwise 2.  
     *   
     * @param code  
     *            int disposal code.  
     */    
    public void setDispose(int code)    
    {    
        if (code >= 0)    
        {    
            dispose = code;    
        }    
    }    
    
    /**  
     * Sets the number of times the set of GIF frames  
     * should be played. Default is 1; 0 means play  
     * indefinitely. Must be invoked before the first  
     * image is added.  
     *  
     * @param iter  
     *            int number of iterations.  
     * @return  
     */    
    public void setRepeat(int iter)    
    {    
        if (iter >= 0)    
        {    
            repeat = iter;    
        }    
    }    
    
    /**  
     * Sets the transparent color for the last added frame  
     * and any subsequent frames.  
     * Since all colors are subject to modification  
     * in the quantization process, the color in the final  
     * palette for each frame closest to the given color  
     * becomes the transparent color for that frame.  
     * May be set to null to indicate no transparent color.  
     *  
     * @param c  
     *            Color to be treated as transparent on display.  
     */    
    public void setTransparent(Color c)    
    {    
        transparent = c;    
    }    
    
    /**  
     * Adds next GIF frame. The frame is not written immediately, but is  
     * actually deferred until the next frame is received so that timing  
     * data can be inserted. Invoking <code>finish()</code> flushes all  
     * frames. If <code>setSize</code> was not invoked, the size of the  
     * first image is used for all subsequent frames.  
     *  
     * @param im  
     *            BufferedImage containing frame to write.  
     * @return true if successful.  
     */    
    public boolean addFrame(BufferedImage im)    
    {    
        if ((im == null) || !started)    
        {    
            return false;    
        }    
        boolean ok = true;    
        try    
        {    
            if (!sizeSet)    
            {    
                // use first frame's size    
                setSize(im.getWidth(), im.getHeight());    
            }    
            image = im;    
            getImagePixels(); // convert to correct format if necessary    
            analyzePixels(); // build color table & map pixels    
            if (firstFrame)    
            {    
                writeLSD(); // logical screen descriptior    
                writePalette(); // global color table    
                if (repeat >= 0)    
                {    
                    // use NS app extension to indicate reps    
                    writeNetscapeExt();    
                }    
            }    
            writeGraphicCtrlExt(); // write graphic control extension    
            writeImageDesc(); // image descriptor    
            if (!firstFrame)    
            {    
                writePalette(); // local color table    
            }    
            writePixels(); // encode and write pixel data    
            firstFrame = false;    
        }    
        catch (IOException e)    
        {    
            ok = false;    
        }    
    
        return ok;    
    }    
    
    // added by alvaro    
    public boolean outFlush()    
    {    
        boolean ok = true;    
        try    
        {    
            out.flush();    
            return ok;    
        }    
        catch (IOException e)    
        {    
            ok = false;    
        }    
    
        return ok;    
    }    
    
    public byte[] getFrameByteArray()    
    {    
        return ((ByteArrayOutputStream) out).toByteArray();    
    }    
    
    /**  
     * Flushes any pending data and closes output file.  
     * If writing to an OutputStream, the stream is not  
     * closed.  
     */    
    public boolean finish()    
    {    
        if (!started)    
            return false;    
        boolean ok = true;    
        started = false;    
        try    
        {    
            out.write(0x3b); // gif trailer    
            out.flush();    
            if (closeStream)    
            {    
                out.close();    
            }    
        }    
        catch (IOException e)    
        {    
            ok = false;    
        }    
    
        return ok;    
    }    
    
    public void reset()    
    {    
        // reset for subsequent use    
        transIndex = 0;    
        out = null;    
        image = null;    
        pixels = null;    
        indexedPixels = null;    
        colorTab = null;    
        closeStream = false;    
        firstFrame = true;    
    }    
    
    /**  
     * Sets frame rate in frames per second. Equivalent to  
     * <code>setDelay(1000/fps)</code>.  
     *  
     * @param fps  
     *            float frame rate (frames per second)  
     */    
    public void setFrameRate(float fps)    
    {    
        if (fps != 0f)    
        {    
            delay = Math.round(100f / fps);    
        }    
    }    
    
    /**  
     * Sets quality of color quantization (conversion of images  
     * to the maximum 256 colors allowed by the GIF specification).  
     * Lower values (minimum = 1) produce better colors, but slow  
     * processing significantly. 10 is the default, and produces  
     * good color mapping at reasonable speeds. Values greater  
     * than 20 do not yield significant improvements in speed.  
     *  
     * @param quality  
     *            int greater than 0.  
     * @return  
     */    
    public void setQuality(int quality)    
    {    
        if (quality < 1)    
            quality = 1;    
        sample = quality;    
    }    
    
    /**  
     * Sets the GIF frame size. The default size is the  
     * size of the first frame added if this method is  
     * not invoked.  
     *  
     * @param w  
     *            int frame width.  
     * @param h  
     *            int frame width.  
     */    
    public void setSize(int w, int h)    
    {    
        if (started && !firstFrame)    
            return;    
        width = w;    
        height = h;    
        if (width < 1)    
            width = 320;    
        if (height < 1)    
            height = 240;    
        sizeSet = true;    
    }    
    
    /**  
     * Initiates GIF file creation on the given stream. The stream  
     * is not closed automatically.  
     *  
     * @param os  
     *            OutputStream on which GIF images are written.  
     * @return false if initial write failed.  
     */    
    public boolean start(OutputStream os)    
    {    
        if (os == null)    
            return false;    
        boolean ok = true;    
        closeStream = false;    
        out = os;    
        try    
        {    
            writeString("GIF89a"); // header    
        }    
        catch (IOException e)    
        {    
            ok = false;    
        }    
        return started = ok;    
    }    
    
    /**  
     * Initiates writing of a GIF file with the specified name.  
     *  
     * @param file  
     *            String containing output file name.  
     * @return false if open or initial write failed.  
     */    
    public boolean start(String file)    
    {    
        boolean ok = true;    
        try    
        {    
            out = new BufferedOutputStream(new FileOutputStream(file));    
            ok = start(out);    
            closeStream = true;    
        }    
        catch (IOException e)    
        {    
            ok = false;    
        }    
        return started = ok;    
    }    
    
    /**  
     * Analyzes image colors and creates color map.  
     */    
    protected void analyzePixels()    
    {    
        int len = pixels.length;    
        int nPix = len / 3;    
        indexedPixels = new byte[nPix];    
        Quant nq = new Quant(pixels, len, sample);    
        // initialize quantizer    
        colorTab = nq.process(); // create reduced palette    
        // convert map from BGR to RGB    
        for (int i = 0; i < colorTab.length; i += 3)    
        {    
            byte temp = colorTab[i];    
            colorTab[i] = colorTab[i + 2];    
            colorTab[i + 2] = temp;    
            usedEntry[i / 3] = false;    
        }    
        // map image pixels to new palette    
        int k = 0;    
        for (int i = 0; i < nPix; i++)    
        {    
            int index = nq.map(pixels[k++] & 0xff, pixels[k++] & 0xff, pixels[k++] & 0xff);    
            usedEntry[index] = true;    
            indexedPixels[i] = (byte) index;    
        }    
        pixels = null;    
        colorDepth = 8;    
        palSize = 7;    
        // get closest match to transparent color if specified    
        if (transparent != null)    
        {    
            transIndex = findClosest(transparent);    
        }    
    }    
    
    /**  
     * Returns index of palette color closest to c  
     */    
    protected int findClosest(Color c)    
    {    
        if (colorTab == null)    
            return -1;    
        int r = c.getRed();    
        int g = c.getGreen();    
        int b = c.getBlue();    
        int minpos = 0;    
        int dmin = 256 * 256 * 256;    
        int len = colorTab.length;    
        for (int i = 0; i < len;)    
        {    
            int dr = r - (colorTab[i++] & 0xff);    
            int dg = g - (colorTab[i++] & 0xff);    
            int db = b - (colorTab[i] & 0xff);    
            int d = dr * dr + dg * dg + db * db;    
            int index = i / 3;    
            if (usedEntry[index] && (d < dmin))    
            {    
                dmin = d;    
                minpos = index;    
            }    
            i++;    
        }    
        return minpos;    
    }    
    
    /**  
     * Extracts image pixels into byte array "pixels"  
     */    
    protected void getImagePixels()    
    {    
        int w = image.getWidth();    
        int h = image.getHeight();    
        int type = image.getType();    
        if ((w != width) || (h != height) || (type != BufferedImage.TYPE_3BYTE_BGR))    
        {    
            // create new image with right size/format    
            BufferedImage temp = new BufferedImage(width, height, BufferedImage.TYPE_3BYTE_BGR);    
            Graphics2D g = temp.createGraphics();    
            g.drawImage(image, 0, 0, null);    
            image = temp;    
        }    
        pixels = ((DataBufferByte) image.getRaster().getDataBuffer()).getData();    
    }    
    
    /**  
     * Writes Graphic Control Extension  
     */    
    protected void writeGraphicCtrlExt() throws IOException    
    {    
        out.write(0x21); // extension introducer    
        out.write(0xf9); // GCE label    
        out.write(4); // data block size    
        int transp, disp;    
        if (transparent == null)    
        {    
            transp = 0;    
            disp = 0; // dispose = no action    
        }    
        else    
        {    
            transp = 1;    
            disp = 2; // force clear if using transparent color    
        }    
        if (dispose >= 0)    
        {    
            disp = dispose & 7; // user override    
        }    
        disp <<= 2;    
    
        // packed fields    
        out.write(0 | // 1:3 reserved    
                disp | // 4:6 disposal    
                0 | // 7 user input - 0 = none    
                transp); // 8 transparency flag    
    
        writeShort(delay); // delay x 1/100 sec    
        out.write(transIndex); // transparent color index    
        out.write(0); // block terminator    
    }    
    
    /**  
     * Writes Image Descriptor  
     */    
    protected void writeImageDesc() throws IOException    
    {    
        out.write(0x2c); // image separator    
        writeShort(0); // image position x,y = 0,0    
        writeShort(0);    
        writeShort(width); // image size    
        writeShort(height);    
        // packed fields    
        if (firstFrame)    
        {    
            // no LCT - GCT is used for first (or only) frame    
            out.write(0);    
        }    
        else    
        {    
            // specify normal LCT    
            out.write(0x80 | // 1 local color table 1=yes    
                    0 | // 2 interlace - 0=no    
                    0 | // 3 sorted - 0=no    
                    0 | // 4-5 reserved    
                    palSize); // 6-8 size of color table    
        }    
    }    
    
    /**  
     * Writes Logical Screen Descriptor  
     */    
    protected void writeLSD() throws IOException    
    {    
        // logical screen size    
        writeShort(width);    
        writeShort(height);    
        // packed fields    
        out.write((0x80 | // 1 : global color table flag = 1 (gct used)    
                0x70 | // 2-4 : color resolution = 7    
                0x00 | // 5 : gct sort flag = 0    
                palSize)); // 6-8 : gct size    
    
        out.write(0); // background color index    
        out.write(0); // pixel aspect ratio - assume 1:1    
    }    
    
    /**  
     * Writes Netscape application extension to define  
     * repeat count.  
     */    
    protected void writeNetscapeExt() throws IOException    
    {    
        out.write(0x21); // extension introducer    
        out.write(0xff); // app extension label    
        out.write(11); // block size    
        writeString("NETSCAPE" + "2.0"); // app id + auth code    
        out.write(3); // sub-block size    
        out.write(1); // loop sub-block id    
        writeShort(repeat); // loop count (extra iterations, 0=repeat forever)    
        out.write(0); // block terminator    
    }    
    
    /**  
     * Writes color table  
     */    
    protected void writePalette() throws IOException    
    {    
        out.write(colorTab, 0, colorTab.length);    
        int n = (3 * 256) - colorTab.length;    
        for (int i = 0; i < n; i++)    
        {    
            out.write(0);    
        }    
    }    
    
    /**  
     * Encodes and writes pixel data  
     */    
    protected void writePixels() throws IOException    
    {    
        Encoder encoder = new Encoder(width, height, indexedPixels, colorDepth);    
        encoder.encode(out);    
    }    
    
    /**  
     * Write 16-bit value to output stream, LSB first  
     */    
    protected void writeShort(int value) throws IOException    
    {    
        out.write(value & 0xff);    
        out.write((value >> 8) & 0xff);    
    }    
    
    /**  
     * Writes string to output stream  
     */    
    protected void writeString(String s) throws IOException    
    {    
        for (int i = 0; i < s.length(); i++)    
        {    
            out.write((byte) s.charAt(i));    
        }    
    }    
}  
```  
### IV、Quant 
```java
package com.test.test;    
    
import java.io.FileNotFoundException;    
import java.io.FileOutputStream;    
    
/**  
 * <p>  
 * </p>  
 *  
 * @author: wuhongjun  
 * @version:1.0  
 */    
public class Quant    
{    
    protected static final int netsize = 256; /* number of colours used */    
    
    /* four primes near 500 - assume no image has a length so large */    
    /* that it is divisible by all four primes */    
    protected static final int prime1 = 499;    
    protected static final int prime2 = 491;    
    protected static final int prime3 = 487;    
    protected static final int prime4 = 503;    
    
    protected static final int minpicturebytes = (3 * prime4);    
    /* minimum size for input image */    
    
    /*  
     * Program Skeleton  
     * ----------------  
     * [select samplefac in range 1..30]  
     * [read image from input file]  
     * pic = (unsigned char*) malloc(3*width*height);  
     * initnet(pic,3*width*height,samplefac);  
     * learn();  
     * unbiasnet();  
     * [write output image header, using writecolourmap(f)]  
     * inxbuild();  
     * write output image using inxsearch(b,g,r)  
     */    
    
    /*  
     * Network Definitions  
     * -------------------  
     */    
    
    protected static final int maxnetpos = (netsize - 1);    
    protected static final int netbiasshift = 4; /* bias for colour values */    
    protected static final int ncycles = 100; /* no. of learning cycles */    
    
    /* defs for freq and bias */    
    protected static final int intbiasshift = 16; /* bias for fractions */    
    protected static final int intbias = (((int) 1) << intbiasshift);    
    protected static final int gammashift = 10; /* gamma = 1024 */    
    protected static final int gamma = (((int) 1) << gammashift);    
    protected static final int betashift = 10;    
    protected static final int beta = (intbias >> betashift); /* beta = 1/1024 */    
    protected static final int betagamma = (intbias << (gammashift - betashift));    
    
    /* defs for decreasing radius factor */    
    protected static final int initrad = (netsize >> 3); /* for 256 cols, radius starts */    
    protected static final int radiusbiasshift = 6; /* at 32.0 biased by 6 bits */    
    protected static final int radiusbias = (((int) 1) << radiusbiasshift);    
    protected static final int initradius = (initrad * radiusbias); /* and decreases by a */    
    protected static final int radiusdec = 30; /* factor of 1/30 each cycle */    
    
    /* defs for decreasing alpha factor */    
    protected static final int alphabiasshift = 10; /* alpha starts at 1.0 */    
    protected static final int initalpha = (((int) 1) << alphabiasshift);    
    
    protected int alphadec; /* biased by 10 bits */    
    
    /* radbias and alpharadbias used for radpower calculation */    
    protected static final int radbiasshift = 8;    
    protected static final int radbias = (((int) 1) << radbiasshift);    
    protected static final int alpharadbshift = (alphabiasshift + radbiasshift);    
    protected static final int alpharadbias = (((int) 1) << alpharadbshift);    
    
    /*  
     * Types and Global Variables  
     * --------------------------  
     */    
    
    protected byte[] thepicture; /* the input image itself */    
    protected int lengthcount; /* lengthcount = H*W*3 */    
    
    protected int samplefac; /* sampling factor 1..30 */    
    
    // typedef int pixel[4]; /* BGRc */    
    protected int[][] network; /* the network itself - [netsize][4] */    
    
    protected int[] netindex = new int[256];    
    /* for network lookup - really 256 */    
    
    protected int[] bias = new int[netsize];    
    /* bias and freq arrays for learning */    
    protected int[] freq = new int[netsize];    
    protected int[] radpower = new int[initrad];    
    /* radpower for precomputation */    
    
    /*  
     * Initialise network in range (0,0,0) to (255,255,255) and set parameters  
     * -----------------------------------------------------------------------  
     */    
    public Quant(byte[] thepic, int len, int sample)    
    {    
    
        int i;    
        int[] p;    
    
        thepicture = thepic;    
        lengthcount = len;    
        samplefac = sample;    
    
        network = new int[netsize][];    
        for (i = 0; i < netsize; i++)    
        {    
            network[i] = new int[4];    
            p = network[i];    
            p[0] = p[1] = p[2] = (i << (netbiasshift + 8)) / netsize;    
            freq[i] = intbias / netsize; /* 1/netsize */    
            bias[i] = 0;    
        }    
    }    
    
    public byte[] colorMap()    
    {    
        byte[] map = new byte[3 * netsize];    
        int[] index = new int[netsize];    
        for (int i = 0; i < netsize; i++)    
            index[network[i][3]] = i;    
        int k = 0;    
        for (int i = 0; i < netsize; i++)    
        {    
            int j = index[i];    
            map[k++] = (byte) (network[j][0]);    
            map[k++] = (byte) (network[j][1]);    
            map[k++] = (byte) (network[j][2]);    
        }    
        return map;    
    }    
    
    /*  
     * Insertion sort of network and building of netindex[0..255] (to do after unbias)  
     * -------------------------------------------------------------------------------  
     */    
    public void inxbuild()    
    {    
    
        int i, j, smallpos, smallval;    
        int[] p;    
        int[] q;    
        int previouscol, startpos;    
    
        previouscol = 0;    
        startpos = 0;    
        for (i = 0; i < netsize; i++)    
        {    
            p = network[i];    
            smallpos = i;    
            smallval = p[1]; /* index on g */    
            /* find smallest in i..netsize-1 */    
            for (j = i + 1; j < netsize; j++)    
            {    
                q = network[j];    
                if (q[1] < smallval)    
                { /* index on g */    
                    smallpos = j;    
                    smallval = q[1]; /* index on g */    
                }    
            }    
            q = network[smallpos];    
            /* swap p (i) and q (smallpos) entries */    
            if (i != smallpos)    
            {    
                j = q[0];    
                q[0] = p[0];    
                p[0] = j;    
                j = q[1];    
                q[1] = p[1];    
                p[1] = j;    
                j = q[2];    
                q[2] = p[2];    
                p[2] = j;    
                j = q[3];    
                q[3] = p[3];    
                p[3] = j;    
            }    
            /* smallval entry is now in position i */    
            if (smallval != previouscol)    
            {    
                netindex[previouscol] = (startpos + i) >> 1;    
                for (j = previouscol + 1; j < smallval; j++)    
                    netindex[j] = i;    
                previouscol = smallval;    
                startpos = i;    
            }    
        }    
        netindex[previouscol] = (startpos + maxnetpos) >> 1;    
        for (j = previouscol + 1; j < 256; j++)    
            netindex[j] = maxnetpos; /* really 256 */    
    }    
    
    /*  
     * Main Learning Loop  
     * ------------------  
     */    
    public void learn()    
    {    
    
        int i, j, b, g, r;    
        int radius, rad, alpha, step, delta, samplepixels;    
        byte[] p;    
        int pix, lim;    
    
        if (lengthcount < minpicturebytes)    
            samplefac = 1;    
        alphadec = 30 + ((samplefac - 1) / 3);    
        p = thepicture;    
        pix = 0;    
        lim = lengthcount;    
        samplepixels = lengthcount / (3 * samplefac);    
        delta = samplepixels / ncycles;    
        alpha = initalpha;    
        radius = initradius;    
    
        rad = radius >> radiusbiasshift;    
        if (rad <= 1)    
            rad = 0;    
        for (i = 0; i < rad; i++)    
            radpower[i] = alpha * (((rad * rad - i * i) * radbias) / (rad * rad));    
    
        // fprintf(stderr,"beginning 1D learning: initial radius=%d\n", rad);    
    
        if (lengthcount < minpicturebytes)    
            step = 3;    
        else if ((lengthcount % prime1) != 0)    
            step = 3 * prime1;    
        else    
        {    
            if ((lengthcount % prime2) != 0)    
                step = 3 * prime2;    
            else    
            {    
                if ((lengthcount % prime3) != 0)    
                    step = 3 * prime3;    
                else    
                    step = 3 * prime4;    
            }    
        }    
    
        i = 0;    
        while (i < samplepixels)    
        {    
            b = (p[pix + 0] & 0xff) << netbiasshift;    
            g = (p[pix + 1] & 0xff) << netbiasshift;    
            r = (p[pix + 2] & 0xff) << netbiasshift;    
            j = contest(b, g, r);    
    
            altersingle(alpha, j, b, g, r);    
            if (rad != 0)    
                alterneigh(rad, j, b, g, r); /* alter neighbours */    
    
            pix += step;    
            if (pix >= lim)    
                pix -= lengthcount;    
    
            i++;    
            if (delta == 0)    
                delta = 1;    
            if (i % delta == 0)    
            {    
                alpha -= alpha / alphadec;    
                radius -= radius / radiusdec;    
                rad = radius >> radiusbiasshift;    
                if (rad <= 1)    
                    rad = 0;    
                for (j = 0; j < rad; j++)    
                    radpower[j] = alpha * (((rad * rad - j * j) * radbias) / (rad * rad));    
            }    
        }    
        // fprintf(stderr,"finished 1D learning: final alpha=%f !\n",((float)alpha)/initalpha);    
    }    
    
    /*  
     * Search for BGR values 0..255 (after net is unbiased) and return colour index  
     * ----------------------------------------------------------------------------  
     */    
    public int map(int b, int g, int r)    
    {    
    
        int i, j, dist, a, bestd;    
        int[] p;    
        int best;    
    
        bestd = 1000; /* biggest possible dist is 256*3 */    
        best = -1;    
        i = netindex[g]; /* index on g */    
        j = i - 1; /* start at netindex[g] and work outwards */    
    
        while ((i < netsize) || (j >= 0))    
        {    
            if (i < netsize)    
            {    
                p = network[i];    
                dist = p[1] - g; /* inx key */    
                if (dist >= bestd)    
                    i = netsize; /* stop iter */    
                else    
                {    
                    i++;    
                    if (dist < 0)    
                        dist = -dist;    
                    a = p[0] - b;    
                    if (a < 0)    
                        a = -a;    
                    dist += a;    
                    if (dist < bestd)    
                    {    
                        a = p[2] - r;    
                        if (a < 0)    
                            a = -a;    
                        dist += a;    
                        if (dist < bestd)    
                        {    
                            bestd = dist;    
                            best = p[3];    
                        }    
                    }    
                }    
            }    
            if (j >= 0)    
            {    
                p = network[j];    
                dist = g - p[1]; /* inx key - reverse dif */    
                if (dist >= bestd)    
                    j = -1; /* stop iter */    
                else    
                {    
                    j--;    
                    if (dist < 0)    
                        dist = -dist;    
                    a = p[0] - b;    
                    if (a < 0)    
                        a = -a;    
                    dist += a;    
                    if (dist < bestd)    
                    {    
                        a = p[2] - r;    
                        if (a < 0)    
                            a = -a;    
                        dist += a;    
                        if (dist < bestd)    
                        {    
                            bestd = dist;    
                            best = p[3];    
                        }    
                    }    
                }    
            }    
        }    
        return (best);    
    }    
    
    public byte[] process()    
    {    
        learn();    
        unbiasnet();    
        inxbuild();    
        return colorMap();    
    }    
    
    /*  
     * Unbias network to give byte values 0..255 and record position i to prepare for sort  
     * -----------------------------------------------------------------------------------  
     */    
    public void unbiasnet()    
    {    
    
        int i, j;    
    
        for (i = 0; i < netsize; i++)    
        {    
            network[i][0] >>= netbiasshift;    
            network[i][1] >>= netbiasshift;    
            network[i][2] >>= netbiasshift;    
            network[i][3] = i; /* record colour no */    
        }    
    }    
    
    /*  
     * Move adjacent neurons by precomputed alpha*(1-((i-j)^2/[r]^2)) in radpower[|i-j|]  
     * ---------------------------------------------------------------------------------  
     */    
    protected void alterneigh(int rad, int i, int b, int g, int r)    
    {    
    
        int j, k, lo, hi, a, m;    
        int[] p;    
    
        lo = i - rad;    
        if (lo < -1)    
            lo = -1;    
        hi = i + rad;    
        if (hi > netsize)    
            hi = netsize;    
    
        j = i + 1;    
        k = i - 1;    
        m = 1;    
        while ((j < hi) || (k > lo))    
        {    
            a = radpower[m++];    
            if (j < hi)    
            {    
                p = network[j++];    
                try    
                {    
                    p[0] -= (a * (p[0] - b)) / alpharadbias;    
                    p[1] -= (a * (p[1] - g)) / alpharadbias;    
                    p[2] -= (a * (p[2] - r)) / alpharadbias;    
                }    
                catch (Exception e)    
                {    
                } // prevents 1.3 miscompilation    
            }    
            if (k > lo)    
            {    
                p = network[k--];    
                try    
                {    
                    p[0] -= (a * (p[0] - b)) / alpharadbias;    
                    p[1] -= (a * (p[1] - g)) / alpharadbias;    
                    p[2] -= (a * (p[2] - r)) / alpharadbias;    
                }    
                catch (Exception e)    
                {    
                }    
            }    
        }    
    }    
    
    /*  
     * Move neuron i towards biased (b,g,r) by factor alpha  
     * ----------------------------------------------------  
     */    
    protected void altersingle(int alpha, int i, int b, int g, int r)    
    {    
    
        /* alter hit neuron */    
        int[] n = network[i];    
        n[0] -= (alpha * (n[0] - b)) / initalpha;    
        n[1] -= (alpha * (n[1] - g)) / initalpha;    
        n[2] -= (alpha * (n[2] - r)) / initalpha;    
    }    
    
    /*  
     * Search for biased BGR values  
     * ----------------------------  
     */    
    protected int contest(int b, int g, int r)    
    {    
    
        /* finds closest neuron (min dist) and updates freq */    
        /* finds best neuron (min dist-bias) and returns position */    
        /* for frequently chosen neurons, freq[i] is high and bias[i] is negative */    
        /* bias[i] = gamma*((1/netsize)-freq[i]) */    
    
        int i, dist, a, biasdist, betafreq;    
        int bestpos, bestbiaspos, bestd, bestbiasd;    
        int[] n;    
    
        bestd = ~(((int) 1) << 31);    
        bestbiasd = bestd;    
        bestpos = -1;    
        bestbiaspos = bestpos;    
    
        for (i = 0; i < netsize; i++)    
        {    
            n = network[i];    
            dist = n[0] - b;    
            if (dist < 0)    
                dist = -dist;    
            a = n[1] - g;    
            if (a < 0)    
                a = -a;    
            dist += a;    
            a = n[2] - r;    
            if (a < 0)    
                a = -a;    
            dist += a;    
            if (dist < bestd)    
            {    
                bestd = dist;    
                bestpos = i;    
            }    
            biasdist = dist - ((bias[i]) >> (intbiasshift - netbiasshift));    
            if (biasdist < bestbiasd)    
            {    
                bestbiasd = biasdist;    
                bestbiaspos = i;    
            }    
            betafreq = (freq[i] >> betashift);    
            freq[i] -= betafreq;    
            bias[i] += (betafreq << gammashift);    
        }    
        freq[bestpos] += beta;    
        bias[bestpos] -= betagamma;    
        return (bestbiaspos);    
    }    
}  
```    