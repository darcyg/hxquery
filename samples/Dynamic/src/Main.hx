import haxe.Json;
import nme.events.MouseEvent;
import nme.Assets;
import nme.text.TextFormat;
import nme.text.TextField;
import com.roxstudio.haxe.hxquery.DynamicVisitor;
import com.roxstudio.haxe.hxquery.HxQuery;
import com.roxstudio.haxe.hxquery.TreeVisitor;
import nme.display.Sprite;

using StringTools;

class Main extends Sprite {

    private var selected: Array<Wrapper>;
    private var v: TreeVisitor<Wrapper>;

    public function new() {
        super();
        var stage = nme.Lib.current.stage;
        var width = stage.stageWidth;
        var height = stage.stageHeight;
        selected = [];

        var json = Json.parse(Assets.getText("res/sample.json"));
        var hash1 = new Hash<{name: String, age: Int}>();
        hash1.set("rockswang", { name: "Rocks Wang", age: 35 });
        hash1.set("qiqi", { name: "Yuxi Wang", age: 4 });
        hash1.set("liyue", { name: "Yue Li", age: 30 });
        var hash2 = new IntHash<Int>();
        hash2.set(100, 50);
        hash2.set(23, 123);
        hash2.set(11, 83);
        var input = [ DynamicVisitor.wrapper(json, "root"), DynamicVisitor.wrapper(hash1, "hash"), DynamicVisitor.wrapper(hash2, "inthash") ];
        v = new DynamicVisitor();

        var tf = text(0, 12, false, true, width, height - 30);
        tf.text = v.createQuery(input).dump();
        stage.addChild(tf);

        var inp = text(0, 16, true, false, width - 100, 20);
        var inpWrap = new Sprite();
        inpWrap.addChild(inp);
        inpWrap.graphics.lineStyle(1, 0);
        inpWrap.graphics.drawRect(0, 0, width - 20, 20);
        inpWrap.x = 0;
        inpWrap.y = height - 22;
        inp.text = "*";
        stage.addChild(inpWrap);

        var btn = new Sprite();
        btn.mouseEnabled = true;
        btn.graphics.lineStyle(1, 0);
        btn.graphics.beginFill(0x0000FF);
        btn.graphics.drawRect(0, 0, 80, 20);
        var btnLabel = text(0, 12, false, true, 50, 20);
        btnLabel.text = "Select";
        btnLabel.x = (80 - btnLabel.textWidth) / 2;
        btnLabel.y = (20 - btnLabel.textHeight) / 2;
        btn.addChild(btnLabel);
        btn.addEventListener(MouseEvent.CLICK, function(_) {
            var nodes: HxQuery<Wrapper> = v.createQuery(input).select(inp.text);
            selected = nodes.elements.copy();
//            var title = v.createQuery(input).select("#title").elements[0];
            tf.text = v.createQuery(input).dump(jsonToString);
//            var cmp: Xml -> Xml -> Bool = Reflect.field(Xml, "compare");
//            for (x in selected) {
//                var aa: Bool = cmp(x, title);
//                trace("aa=" + aa);
//            }
//            trace("result=" + nodes);
        });
        btn.x = width - 80;
        btn.y = height - 22;
        stage.addChild(btn);

    }

    private function jsonToString(n: Wrapper) : String {
        var sel = Lambda.has(selected, n, function(n1: Wrapper, n2: Wrapper) : Bool {
            return v.equals(n1, n2);
        });
        return sel ? "[ " + v.toString(n) + " ]" : v.toString(n);
    }

    private static function text(color: Int, size: Float, input: Bool, multiline: Bool, width: Float, height: Float) : TextField {
        var tf = new TextField();
        tf.selectable = tf.mouseEnabled = input;
        if (input) tf.type = nme.text.TextFieldType.INPUT;
        tf.defaultTextFormat = textFormat(color, size);
        tf.multiline = tf.wordWrap = multiline;
        tf.width = width;
        tf.height = height;
        tf.x = tf.y = 0;
        return tf;
    }

    private static function textFormat(color: Int, size: Float) : TextFormat {
        var format = new TextFormat();
#if android
        format.font = new nme.text.Font("/system/fonts/DroidSansFallback.ttf").fontName;
//#else
//        format.font = "Microsoft YaHei";
#end
        format.color = color;
        format.size = Std.int(size);
        return format;
    }

    public static function main() {
        new Main();
    }

}
