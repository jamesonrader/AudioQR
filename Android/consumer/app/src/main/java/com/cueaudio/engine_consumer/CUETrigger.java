package com.cueaudio.engine_consumer;

import android.annotation.SuppressLint;
import android.support.annotation.IntRange;
import android.support.annotation.Nullable;

import com.google.gson.annotations.SerializedName;

import java.util.Arrays;

public class CUETrigger {
    @SerializedName("mode")
    private String mode;
    @SerializedName("latency_ms")
    private float latency;
    @SerializedName("noise")
    private double noise;
    @SerializedName("power")
    private double power;
    @SerializedName("num-symbols")
    private int numSymbols;
    @SerializedName("raw-indices")
    private String indices;
    @SerializedName("raw-calib")
    @Nullable
    private double[] rawCalib;
    @SerializedName("raw-trigger")
    @Nullable
    private double[][] rawTrigger;
    @SerializedName("winner-binary")
    private String winnerBinary;
    @SerializedName("winner-indices")
    private String winnerIndices;

    /**
     * New model with parse latency.
     * @param delay parse latency
     * @return model with parse latency
     */
    public CUETrigger withParseLatency(@IntRange(from = 0) long delay) {
        final CUETrigger result = new CUETrigger();
        result.mode = getMode();
        result.latency = getLatency() + delay;
        result.noise = getNoise();
        result.indices = getIndices();
        result.power = getPower();
        result.numSymbols = getNumSymbols();
        result.rawCalib = getRawCalib();
        result.rawTrigger = getRawTrigger();
        result.winnerBinary = getWinnerBinary();
        result.winnerIndices = getWinnerIndices();
        return result;
    }

    public float getLatency() {
        return latency;
    }

    public String getMode() {
        return mode;
    }

    public double getNoise() {
        return noise;
    }

    public int getNumSymbols() {
        return numSymbols;
    }

    public double getPower() {
        return power;
    }

    public String getIndices() {
        return indices;
    }

    @Nullable
    public double[] getRawCalib() {
        if (rawCalib != null) {
            return Arrays.copyOf(rawCalib, rawCalib.length);
        }
        return null;
    }

    @Nullable
    public double[][] getRawTrigger() {
        if (rawTrigger == null) {
            return null;
        }
        final int count = rawTrigger.length;
        final double[][] result = new double[count][];
        for (int i = 0; i < count; i++) {
            result[i] = Arrays.copyOf(rawTrigger[i], rawTrigger[i].length);
        }
        return result;
    }

    public String getWinnerBinary() {
        return winnerBinary;
    }

    public String getWinnerIndices() {
        return winnerIndices;
    }

    public String toShortString() {
        return "CUESymbols {" +
                "\n  mode='" + mode + '\'' +
                "\n  indices=" + indices +
                "\n  latency=" + String.format("%.2f", latency) +
                "\n}";
    }

    @SuppressLint("DefaultLocale")
    @Override
    public String toString() {
        return "CUESymbols {" +
                "\n  mode='" + mode + '\'' +
                "\n  indices=" + indices +
                "\n  latency=" + String.format("%.2f", latency) +
                "\n  noise=" + String.format("%.2f", noise) +
                "\n  power=" + String.format("%.2f", power) +
                "\n  numSymbols=" + numSymbols +
                "\n  rawCalib=" + Arrays.toString(rawCalib) +
                "\n  rawTrigger=" + Arrays.deepToString(rawTrigger) +
                "\n  winnerBinary=" + winnerBinary +
                "\n  winnerIndices=" + winnerIndices +
                "\n}";
    }
}