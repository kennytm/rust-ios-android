package kennytm.rustsample;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

public final class RustSampleActivity extends Activity {
    static {
        System.loadLibrary("sample");
    }

    private static native long regexCreate(final String pattern);

    private static native int regexFind(final long regex, final String text);

    private static native void regexDestroy(final long regex);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }

    public final void check(final View view) {
        final String pattern = ((TextView) findViewById(R.id.regexField)).getText().toString();
        final String text = ((TextView) findViewById(R.id.textField)).getText().toString();

        final long regex = regexCreate(pattern);
        final int index;
        if (regex != 0) {
            index = regexFind(regex, text);
            regexDestroy(regex);
        } else {
            index = -1;
        }

        final String message = (index >= 0) ? "Found at " + index : "Not found";
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
}
