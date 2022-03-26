# Simplest SLI we can show

*** Settings ***
Library    RW.Core
         
*** Tasks ***
Push the number '10' as the metric reading for this SLI
    Info Log      Hello world!
    Push Metric   10
