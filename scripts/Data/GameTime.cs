using Godot;

namespace Demo.Data;

public enum Season
{
    Spring,
    Summer,
    Autumn,
    Winter
}

public enum DayPhase
{
    Morning,
    Noon,
    Evening,
    Night
}

public enum SolarTerm
{
    // Spring
    LiChun,
    YuShui,
    JingZhe,
    ChunFen,
    QingMing,
    GuYu,
    // Summer
    LiXia,
    XiaoMan,
    MangZhong,
    XiaZhi,
    XiaoShu,
    DaShu,
    // Autumn
    LiQiu,
    ChuShu,
    BaiLu,
    QiuFen,
    HanLu,
    ShuangJiang,
    // Winter
    LiDong,
    XiaoXue,
    DaXue,
    DongZhi,
    XiaoHan,
    DaHan
}

public struct GameTime
{
    public int Year;
    public Season Season;
    public SolarTerm Term;
    public int DayInTerm; // 1-3
    public DayPhase Phase;
    public int Minute;
}

public struct SolarTermEffect
{
    public float GrowthMultiplier;
    public float WaterCostMultiplier;
    public float PriceMultiplier;
    public string Description;
}

public static class SolarTermHelper
{
    public static Season GetSeason(SolarTerm term)
    {
        return term switch
        {
            SolarTerm.LiChun or SolarTerm.YuShui or SolarTerm.JingZhe or SolarTerm.ChunFen or SolarTerm.QingMing or SolarTerm.GuYu => Season.Spring,
            SolarTerm.LiXia or SolarTerm.XiaoMan or SolarTerm.MangZhong or SolarTerm.XiaZhi or SolarTerm.XiaoShu or SolarTerm.DaShu => Season.Summer,
            SolarTerm.LiQiu or SolarTerm.ChuShu or SolarTerm.BaiLu or SolarTerm.QiuFen or SolarTerm.HanLu or SolarTerm.ShuangJiang => Season.Autumn,
            SolarTerm.LiDong or SolarTerm.XiaoXue or SolarTerm.DaXue or SolarTerm.DongZhi or SolarTerm.XiaoHan or SolarTerm.DaHan => Season.Winter,
            _ => Season.Spring
        };
    }

    public static string GetDisplayName(SolarTerm term)
    {
        return term switch
        {
            SolarTerm.LiChun => "立春",
            SolarTerm.YuShui => "雨水",
            SolarTerm.JingZhe => "惊蛰",
            SolarTerm.ChunFen => "春分",
            SolarTerm.QingMing => "清明",
            SolarTerm.GuYu => "谷雨",
            SolarTerm.LiXia => "立夏",
            SolarTerm.XiaoMan => "小满",
            SolarTerm.MangZhong => "芒种",
            SolarTerm.XiaZhi => "夏至",
            SolarTerm.XiaoShu => "小暑",
            SolarTerm.DaShu => "大暑",
            SolarTerm.LiQiu => "立秋",
            SolarTerm.ChuShu => "处暑",
            SolarTerm.BaiLu => "白露",
            SolarTerm.QiuFen => "秋分",
            SolarTerm.HanLu => "寒露",
            SolarTerm.ShuangJiang => "霜降",
            SolarTerm.LiDong => "立冬",
            SolarTerm.XiaoXue => "小雪",
            SolarTerm.DaXue => "大雪",
            SolarTerm.DongZhi => "冬至",
            SolarTerm.XiaoHan => "小寒",
            SolarTerm.DaHan => "大寒",
            _ => "未知"
        };
    }

    public static string GetSeasonName(Season season)
    {
        return season switch
        {
            Season.Spring => "春",
            Season.Summer => "夏",
            Season.Autumn => "秋",
            Season.Winter => "冬",
            _ => "未知"
        };
    }

    public static string GetPhaseName(DayPhase phase)
    {
        return phase switch
        {
            DayPhase.Morning => "晨",
            DayPhase.Noon => "午",
            DayPhase.Evening => "夕",
            DayPhase.Night => "夜",
            _ => "未知"
        };
    }
}
